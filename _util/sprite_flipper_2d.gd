@tool
@icon("res://Assets/Icons/ico_edr_spr_flip.png")
class_name SpriteFlipper2D
extends Node

@export var char : CharacterBody2D
@export var sprite : Node2D:
	set(node):
		sprite = node
		update_configuration_warnings()

@export_group("Controls")
@export var flip_h : bool = true
@export var flip_v : bool = false

@export_group("Settings")
@export var asymetric : bool = false
@export var offset : bool = false

var untouched_offset

signal update_direction(facing_left : bool)

func _ready() -> void:
	untouched_offset = sprite.offset

func _get_configuration_warnings() -> PackedStringArray:
	if not sprite:
		return ["SpriteFlipper2D needs a Sprite target set to work."]
	elif not sprite is Sprite2D and not sprite is AnimatedSprite2D:
		return ["Target node is not a Sprite2D or AnimatedSprite2D."]
	else:
		return []

func flip_sprite_by_dir(dir : Vector2) -> void:
	if flip_h:
		if dir.x > 0:
			sprite.flip_h = false
			
			if offset:
				sprite.offset.x = abs(untouched_offset.x)
			
			
		elif dir.x < 0:
			sprite.flip_h = true
			
			if offset:
				sprite.offset.x = -untouched_offset.x
		
		emit_signal("update_direction", sprite.flip_h)

func flip_sprite_toward(other_pos : Vector2) -> void:
	var new_dir : Vector2 = sprite.global_position.direction_to(other_pos)
	
	if flip_h and sign(new_dir.x) != 0:
		sprite.flip_h = sign(new_dir.x) == 1
	
	if flip_v and sign(new_dir.y) != 0:
		sprite.flip_v = sign(new_dir.y) == -1
