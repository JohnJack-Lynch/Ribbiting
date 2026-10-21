@icon("res://Assets/Icons/ico_edr_hurtbox.png")
class_name Hurtbox2D
extends Area2D

@export var health : Health

var invincible : bool = false

signal receive_hit(hitbox : Hitbox2D)

func take_hit(hitbox : Hitbox2D) -> void:
	if invincible:
		return
	
	
	emit_signal("receive_hit", hitbox)
