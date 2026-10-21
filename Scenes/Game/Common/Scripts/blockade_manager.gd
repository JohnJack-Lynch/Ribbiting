class_name BlockadeController
extends Node

@export var blockade : Blockade

var switches : Array

var sound_cue : bool = false

@onready var toggle_snd: AudioStreamPlayer2D = $ToggleSnd

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	switches = []
	
	switches = get_tree().get_nodes_in_group("Switches")
	print(switches)

func _physics_process(delta: float) -> void:
	if switches:
		blockade.set_blockade_collision(!switch_check())
	
	if sound_cue != switch_check():
		toggle_snd.play()
		sound_cue = switch_check()

func switch_check() -> bool:
	for s in switches:
		if is_instance_valid(s):
			if s.pressed == false:
				return false
	
	return true
