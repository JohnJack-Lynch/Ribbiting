class_name Level
extends Node2D

@export var next_level_uid : String

@export var player_spawn : Vector2
@export var win_zone_pos : Vector2

var active_frog_count : Array

var total_frog_count : Array

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
	

func _on_refresh_frog_count() -> void:
	#frog_count = get_tree().get_nodes_in_group("ActiveFrog")
	#
	#print(frog_count)
	
	set_frog_count()
	
	if active_frog_count == [] or total_frog_count == []:
		SignalBus.refresh_level.emit()
