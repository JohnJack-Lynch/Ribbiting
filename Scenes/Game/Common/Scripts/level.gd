class_name Level
extends Node2D

@export var level_data : LevelData

@export var next_level_uid : String

@export var player_spawn : Vector2
@export var win_zone_pos : Vector2

var active_frog_count : Array

var total_frog_count : Array

var completed : bool = false

func _ready() -> void:
	#frog_count = get_tree().get_nodes_in_group("ActiveFrog")
	#
	##print(frog_count)
	#
	#var p : int = 0
	#
	#for f in frog_count:
		#f.priority = p
		#p += 1
		#
		#print(f)
		#print(f.priority)
	
	print(self)
	
	set_frog_count()
	
	SignalBus.refresh_frog_count.connect(_on_refresh_frog_count)
	SignalBus.reenable_node.connect(_on_reenable)

func get_player_spawn() -> Vector2:
	return player_spawn + Vector2(8, 8)

func get_win_zone_pos() -> Vector2:
	return win_zone_pos + Vector2(8, 8)

func set_frog_count() -> void:
	active_frog_count = get_tree().get_nodes_in_group("ActiveFrog")
	total_frog_count = get_tree().get_nodes_in_group("Frog")
	
	var p : int = 0
	
	for f in total_frog_count:
		f.priority = p
		p += 1
		
		print(f)
		print(f.priority)

func set_level_enabled(on : bool) -> void:
	for t in get_children():
		if t is TileMapLayer:
			t.enabled = on
	
	if on == false:
		hide()
	else:
		show()

func function_that_sets_all_current_frogs_to_the_win_state() -> void:
	for f in total_frog_count:
		if f is Player:
			f.switch_state(Player.States.WIN)

func set_processes(enabled : bool) -> void:
	set_process(enabled)
	set_physics_process(enabled)


func _on_refresh_frog_count() -> void:
	#frog_count = get_tree().get_nodes_in_group("ActiveFrog")
	#
	#print(frog_count)
	
	set_frog_count()
	
	if active_frog_count == [] or total_frog_count == []:
		SignalBus.refresh_level.emit()

func _on_reenable(game_state : int) -> void:
	if game_state == 1:
		print("reenabled " + name)
		process_mode = Node.PROCESS_MODE_INHERIT
