class_name WorldMap
extends Node2D

var map_nodes : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_nodes = get_tree().get_nodes_in_group("MapNodes")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
