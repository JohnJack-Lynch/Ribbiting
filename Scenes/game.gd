# based on the implementation by Fat Earth Studio

class_name MainGame
extends Node

enum GameState {
	WORLD_MAP,
	GAME,
	SCENE
}

var cur_game_state : GameState = GameState.WORLD_MAP

var next_level : String = ""

var player : Player = null
var win_zone : WinZone = null

var cur_level : Level = null
var cur_level_uid : String = ""

var cur_map : WorldMap = null
var map_player : MapPlayer = null
var cur_map_uid : String = ""
var cur_node_pos : Vector2 = Vector2.ZERO

var initializing : bool = true
var resetting_level : bool = false
var win_zone_instantiated : bool = false

var mus_tween : Tween

const PLAYER_SCENE_UID : String = "uid://5ull6trhjdm7"
const WIN_ZONE_SCENE_UID : String = "uid://mtc50o1t6q8f"

#const MAIN_MENU_SCENE_UID : String = "uid://crh1erkfw5spn"
const LEVEL_1_SCENE_UID : String = "uid://oey1hsl1xs8b"

const MAP_PLAYER_SCENE_UID : String = "uid://cbujyts27bjul"
const WORLD_1_MAP_SCENE_UID : String = "uid://cugjaqj7ne4li"

#const END_SCENE_UID : String = ""

@onready var map_root: Node2D = $World/MapRoot
@onready var level_root: Node2D = $World/LevelRoot
@onready var entity_root: Node2D = $World/EntityRoot
@onready var effect_root: Node2D = $World/EffectRoot

@onready var hud_root: Control = $HUDLayer/HUDRoot
@onready var menu_root: Control = $HUDLayer/MenuRoot

@onready var transition_root: Control = $TransitionLayer/TransitionRoot

@onready var music: AudioStreamPlayer = $Music

@onready var map_cam: MapCam = $World/MapCam
@onready var game_cam: Camera2D = $World/GameCam

@onready var win_banner : Label = $HUDLayer/HUDRoot/Label

signal game_state_changed(new_state : GameState)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.refresh_level.connect(_on_refresh_level)
	SignalBus.go_to_level.connect(_on_go_to_level)
	game_state_changed.connect(_on_game_state_changed)
	
	init_player()
	
	await load_level(LEVEL_1_SCENE_UID)
	await load_scene(WORLD_1_MAP_SCENE_UID, deferred_load_map)
	
	initializing = false
	
	check_game_state(cur_game_state)
	
	Fader.animation_player.play("WipeOut")
	
	if mus_tween:
		mus_tween.kill()
	
	mus_tween = create_tween()
	mus_tween.tween_property(music, "volume_db", -4.5, 8.0)

func _unhandled_input(event: InputEvent) -> void:
	if cur_game_state == GameState.GAME:
		if Input.is_action_just_pressed("RIB_RESET") and !Fader.animation_player.is_playing():
			SignalBus.refresh_level.emit()
		
		if Input.is_action_just_pressed("RIB_CROAK") and cur_level.completed == true:
			Fader.animation_player.play("WipeIn")
			await Fader.animation_player.animation_finished
			
			change_game_state(GameState.WORLD_MAP)

func init_player() -> void:
	var player_inst : PackedScene = ResourceLoader.load(PLAYER_SCENE_UID) as PackedScene
	var map_player_inst : PackedScene = ResourceLoader.load(MAP_PLAYER_SCENE_UID) as PackedScene
	
	if player_inst == null:
		push_error("Could not load player scene " + PLAYER_SCENE_UID)
		return
	
	if map_player_inst == null:
		push_error("Could not load map player scene " + MAP_PLAYER_SCENE_UID)
		return
	
	
	player = player_inst.instantiate() as Player
	
	
	map_player = map_player_inst.instantiate() as MapPlayer
	
	
	if player == null:
		push_error("Loaded player scene does not extend Player or does not exist " + PLAYER_SCENE_UID)
		return
	
	if map_player == null:
		push_error("Loaded map player scene does not extend MapPlayer or does not exist " + MAP_PLAYER_SCENE_UID)
		return
	
	player.active = true
	
	if resetting_level == false:
		entity_root.add_child(map_player)
		print("created map_player instance " + map_player.name)
	
	
	entity_root.add_child(player)
	print("created player instance " + player.name)
	
	match cur_game_state:
		GameState.WORLD_MAP:
			
			map_cam.target = map_player
		GameState.GAME:
			pass

func set_win_zone() -> void:
	var win_zone_inst : PackedScene = ResourceLoader.load(WIN_ZONE_SCENE_UID) as PackedScene
	
	if win_zone_inst == null:
		push_error("Could not load win zone scene " + WIN_ZONE_SCENE_UID)
		return
	
	win_zone = win_zone_inst.instantiate() as WinZone
	
	if win_zone == null:
		push_error("Loaded win zone scene does not extend WinZone or Area2D or does not exist " + WIN_ZONE_SCENE_UID)
		return
	
	get_next_level()
	
	win_zone.body_entered.connect(_on_player_enter)
	
	if win_zone_instantiated == false:
		entity_root.add_child(win_zone)
		win_zone_instantiated = true

func get_next_level() -> void:
	if win_zone == null:
		push_error("Cannot get win zone, win_zone is null")
		return
	if cur_level == null or cur_level.next_level_uid == null:
		push_error("Cannot access next level, cur_level is null or cur_level.next_level_uid is undefined")
		return
	
	next_level = cur_level.next_level_uid

func load_level(level_scene : String) -> void:
	if initializing == false:
		Fader.animation_player.play("WipeIn")
		
		await Fader.animation_player.animation_finished
	
	await deferred_load_level(level_scene)
	
	Fader.animation_player.play("WipeOut")

func deferred_load_level(level_uid : String) -> void:
	if cur_level != null:
		cur_level.queue_free()
		cur_level = null
	
	await get_tree().process_frame
	
	var new_level_inst : PackedScene = ResourceLoader.load(level_uid, "PackedScene") as PackedScene
	
	if new_level_inst == null:
		push_error("Could not load level as PackedScene " + level_uid)
		return
	
	cur_level = new_level_inst.instantiate() as Level
	
	if cur_level == null:
		push_error("Loaded level is not of type Level or does not exist")
		return
	
	level_root.add_child(cur_level)
	
	set_win_zone()
	
	set_refresh_point(level_uid)
	
	await get_tree().process_frame
	place_player_in_init_pos()
	place_win_zone()
	set_win_zone_layers()

func load_scene(target_scene : String, deferred_call : Callable) -> void:
	#if initializing == false:
		#Fader.animation_player.play("WipeIn")
		#
		#await Fader.animation_player.animation_finished
	
	await deferred_call.call(target_scene)
	
	Fader.animation_player.play("WipeOut")

func deferred_load_map(map_uid : String) -> void:
	if cur_map != null:
		cur_map.queue_free()
		cur_map = null
	
	await get_tree().process_frame
	
	var new_map_inst : PackedScene = ResourceLoader.load(map_uid, "PackedScene") as PackedScene
	
	if new_map_inst == null:
		push_error("Could not load map as PackedScene " + map_uid)
		return
	
	cur_map = new_map_inst.instantiate() as WorldMap
	
	if cur_map == null:
		push_error("Loaded map is not of type WorldMap or does not exist")
		return
	
	map_root.add_child(cur_map)
	
	await get_tree().process_frame
	
	place_player_in_init_pos()

func place_player_in_init_pos() -> void:
	match cur_game_state:
		GameState.WORLD_MAP:
			if map_player == null:
				push_error("Cannot place map player, map_player is null")
				return
			
			if cur_map == null:
				push_error("Cannot place player into map, cur_map is null")
				return
				
			map_player.switch_state(map_player.NavStates.MOVE)
			map_player.global_position = cur_map.default_player_pos
		GameState.GAME:
			if player == null:
				push_error("Cannot place player, player is null")
				return
				
			if cur_level == null:
				push_error("Cannot place player into level, cur_level is null")
				return
				
			
			player.switch_state(player.States.ACTIVE)
			player.global_position = cur_level.get_player_spawn()

func place_win_zone() -> void:
	if win_zone == null:
		push_error("Cannot place win zone, win_zone is null")
		return
	if cur_level == null:
		push_error("Cannot place player into level, cur_level is null")
		return
	
	win_zone.global_position = cur_level.get_win_zone_pos()

func set_win_zone_layers() -> void:
	if win_zone == null:
		push_error("Cannot set win zone layers/masks, win_zone is null")
		return
	
	win_zone.set_collision_layer_value(3, true)
	win_zone.set_collision_mask_value(2, true)

func set_refresh_point(uid : String) -> void:
	if cur_level == null:
		push_error("Cannot access the uid of the current scene, cur_level is null")
		return
	
	cur_level_uid = uid

func change_game_state(new_state : GameState) -> void:
	cur_game_state = new_state
	
	check_game_state(new_state)
	Fader.animation_player.play("WipeOut")
	await Fader.animation_player.animation_finished
	
	game_state_changed.emit(new_state)

func check_game_state(s : GameState) -> void:
	print(s)
	
	SignalBus.reenable_node.emit(s)
	
	
	match s:
		
		GameState.WORLD_MAP:
			if map_player:
				print("has map player")
				#map_player.set_processes(true)
				#map_player.show()
				#map_player.switch_state(map_player.NavStates.MOVE)
			
			if cur_map:
				print("has map")
				#cur_map.set_processes(true)
				
				cur_map.set_map_enabled(true)
			#map_root.process_mode = Node.PROCESS_MODE_INHERIT
			#map_root.show()
			
			if player:
				print("has player")
				#player.set_processes(false)
				player.hide()
				player.process_mode = Node.PROCESS_MODE_DISABLED
			
			if cur_level:
				print("has level")
				#cur_level.set_processes(false)
				cur_level.set_level_enabled(false)
				cur_level.process_mode = Node.PROCESS_MODE_DISABLED
			
			#level_root.process_mode = Node.PROCESS_MODE_DISABLED
			#level_root.hide()
			
			map_cam.enabled = true
			game_cam.enabled = false
		GameState.GAME:
			if player:
				#player.set_processes(true)
				player.show()
			
			if cur_level:
				#cur_level.set_processes(true)
				cur_level.set_level_enabled(true)
			
			#level_root.process_mode = Node.PROCESS_MODE_INHERIT
			#level_root.show()
			
			if map_player:
				#map_player.set_processes(false)
				map_player.hide()
				map_player.process_mode = Node.PROCESS_MODE_DISABLED
			
			if cur_map:
				#cur_map.set_processes(false)
				cur_map.set_map_enabled(false)
				cur_map.process_mode = Node.PROCESS_MODE_DISABLED
			
			#map_root.process_mode = Node.PROCESS_MODE_DISABLED
			#map_root.hide()
			
			map_cam.enabled = false
			game_cam.enabled = true
		GameState.SCENE:
			pass
		
	print(map_player.visible)

#func load_end_scene() -> void:
	#if player!= null:
		#player.queue_free()
		#player = null
	#
	#if win_zone != null:
		#win_zone.queue_free()
		#win_zone = null
	#
	#if cur_level != null:
		#cur_level.queue_free()
		#cur_level = null
	#
	#await get_tree().process_frame

# for when the player enters the win zone
func _on_player_enter(body : Node2D) -> void:
	print("body entered")
	print(body)
	
	if body is Player:
		await body.spr_pos_tween.finished
		
		cur_level.completed = true
		# set all frogs to the win state
		cur_level.function_that_sets_all_current_frogs_to_the_win_state()
		
		win_banner.show()
		
		#if next_level == "":
			#
			#
			#
			#
			#Fader.animation_player.play("WipeIn")
			#await Fader.animation_player.animation_finished
			#
			#SignalBus.return_to_menu.emit()
			#
			#get_tree().call_deferred("change_scene_to_file", "res://Scenes/UI/Menus/main_menu.tscn")
			##load_end_scene()
			##
		#else:
			#await body.spr_pos_tween.finished
			#load_level(next_level)
			#
			#await Fader.animation_player.animation_finished
			#win_zone.queue_free()
			#win_zone = null
		#
		#SignalBus.level_complete.emit()

func _on_refresh_level() -> void:
	Fader.animation_player.play("WipeIn")
	await Fader.animation_player.animation_finished
	
	if player!= null:
		player.queue_free()
		player = null
	
	if win_zone != null:
		win_zone.queue_free()
		win_zone = null
	
	initializing = true
	resetting_level = true
	
	init_player()
	
	await load_level(cur_level_uid)
	initializing = false
	resetting_level = false

func _on_game_state_changed(new_state : GameState) -> void:
	pass

func _on_go_to_level(map_uid : String) -> void:
	Fader.animation_player.play("WipeIn")
	await Fader.animation_player.animation_finished
	
	print("going to uid " + map_uid)
	
	change_game_state(GameState.GAME)
	
	if player == null or map_player == null:
		init_player()
	
	await load_scene(map_uid, deferred_load_level)
