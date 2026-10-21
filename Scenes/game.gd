# based on the implementation by Fat Earth Studio

class_name MainGame
extends Node

var next_level : String = ""

var player : Player = null
var win_zone : WinZone = null

var cur_level : Level = null
var cur_level_uid : String = ""

var initializing : bool = true

var mus_tween : Tween

const PLAYER_SCENE_UID : String = "uid://5ull6trhjdm7"
const WIN_ZONE_SCENE_UID : String = "uid://mtc50o1t6q8f"

#const MAIN_MENU_SCENE_UID : String = "uid://crh1erkfw5spn"
const LEVEL_1_SCENE_UID : String = "uid://oey1hsl1xs8b"

const MAIN_MENU_SCENE_UID : String = "uid://crh1erkfw5spn"
const END_SCENE_UID : String = ""

@onready var level_root: Node2D = $World/LevelRoot
@onready var entity_root: Node2D = $World/EntityRoot
@onready var effect_root: Node2D = $World/EffectRoot

@onready var hud_root: Control = $HUDLayer/HUDRoot
@onready var transition_root: Control = $TransitionLayer/TransitionRoot

@onready var music: AudioStreamPlayer = $Music

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_player()
	
	load_level(LEVEL_1_SCENE_UID)
	initializing = false
	Fader.animation_player.play("WipeOut")
	
	if mus_tween:
		mus_tween.kill()
	
	mus_tween = create_tween()
	mus_tween.tween_property(music, "volume_db", -4.5, 8.0)
	
	SignalBus.refresh_level.connect(_on_refresh_level)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_focus_next"):
		SignalBus.refresh_level.emit()

func init_player() -> void:
	var player_inst : PackedScene = ResourceLoader.load(PLAYER_SCENE_UID) as PackedScene
	
	if player_inst == null:
		push_error("Could not load player scene " + PLAYER_SCENE_UID)
		return
	
	player = player_inst.instantiate() as Player
	
	if player == null:
		push_error("Loaded player scene does not extend Player or does not exist " + PLAYER_SCENE_UID)
		return
	
	player.active = true
	entity_root.add_child(player)

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
	entity_root.add_child(win_zone)

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
	
	deferred_load_level.call_deferred(level_scene)
	
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

func place_player_in_init_pos() -> void:
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


func _on_player_enter(body : Node2D) -> void:
	print("body entered")
	print(body)
	if body is Player:
		if next_level == "":
			
			
			await body.spr_pos_tween.finished
			
			Fader.animation_player.play("WipeIn")
			await Fader.animation_player.animation_finished
			
			SignalBus.return_to_menu.emit()
			
			get_tree().call_deferred("change_scene_to_file", "res://Scenes/UI/Menus/main_menu.tscn")
			#load_end_scene()
			#
		else:
			await body.spr_pos_tween.finished
			load_level(next_level)
			
			await Fader.animation_player.animation_finished
			win_zone.queue_free()
			win_zone = null
		
		SignalBus.level_complete.emit()

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
	
	init_player()
	
	load_level(cur_level_uid)
	initializing = false
