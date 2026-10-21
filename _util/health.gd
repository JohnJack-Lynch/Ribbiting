@icon("res://Assets/Icons/ico_edr_health.png")
class_name Health
extends Node

@export var max_health : int
@export var hurtbox : Hurtbox2D

var cur_health : int

func _ready() -> void:
	cur_health = max_health
	
	#hurtbox.receive_hit.connect(_on_receive_hit)

func set_health(val : int) -> void:
	cur_health += val
	
	if cur_health > max_health:
		cur_health = max_health
	
	if cur_health < 0:
		cur_health = 0

func damage(d : int) -> void:
	set_health(-d)

func heal(h : int) -> void:
	set_health(h)

func reset_health() -> void:
	cur_health = max_health

#func _on_receive_hit(hitbox : Hitbox2D) -> void:
	#damage(hitbox.damage)
