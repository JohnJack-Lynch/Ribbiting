class_name Gate
extends Node2D

var switches : Array
var all_pressed : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	switches = get_tree().get_nodes_in_group("Switches")
	print(switches)

func _physics_process(delta: float) -> void:
	pass
