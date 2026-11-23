class_name WorldMap
extends Node2D

@export var default_player_pos : Vector2

var map_nodes : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_nodes = get_tree().get_nodes_in_group("MapNodes")
	
	SignalBus.reenable_node.connect(_on_reenable)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_map_enabled(on : bool) -> void:
	for t in get_children():
		if t is TileMapLayer:
			t.enabled = on
	
	if on == false:
		hide()
	else:
		show()

func set_processes(enabled : bool) -> void:
	set_process(enabled)
	set_physics_process(enabled)


func _on_reenable(game_state : int) -> void:
	if game_state == 0:
		print("reenabled " + name)
		process_mode = Node.PROCESS_MODE_INHERIT
