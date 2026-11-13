class_name LevelBubble
extends Control

@export var name_label : Label
@export var level_label : Label

@export var world_names : Array[String]

@export var anim : AnimationPlayer

func set_label_text(n : String, l : int, w : int) -> void:
	var lvl_text : String = world_names[w] + ": " + str(l)
	
	if l == 0:
		lvl_text = world_names[w]
	
	name_label.text = n
	level_label.text = lvl_text
	
