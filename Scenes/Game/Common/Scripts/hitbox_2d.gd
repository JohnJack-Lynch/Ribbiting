@icon("res://Assets/Icons/ico_edr_hitbox.png")
class_name Hitbox2D
extends Area2D

enum Direction {
	LEFT, # 0
	UP, # 1
	RIGHT, # 2
}

@export var damage : int
@export var knockback_force: float
@export var one_shot : bool = false
@export var direction : Direction

var hitbox_dir : int # determines the knockback direction, controlled by an export enum (see above)

var contact : bool = false
var contacted_hurtboxes : Array[Hurtbox2D]

signal send_hit(hurtbox : Hurtbox2D)

func _init() -> void:
	monitoring = true
	monitorable = false
	set_hit_direction(direction)
	
	area_entered.connect(_on_hurtbox_entered)

func reset() -> void:
	contacted_hurtboxes.clear()
	contact = false

func set_hit_direction(dir : Direction) -> void:
	match dir:
		0:
			hitbox_dir = -1
		1:
			hitbox_dir = 1
		2:
			hitbox_dir = 1

func _on_hurtbox_entered(area : Area2D) -> void:
	if not area is Hurtbox2D:
		return
	
	var hurtbox : Hurtbox2D = area
	contacted_hurtboxes.append(hurtbox)
	var already_hit : bool = one_shot and contact and contacted_hurtboxes.has(hurtbox)
	
	if already_hit or hurtbox.invincible:
		return
	
	contact = true
	hurtbox.take_hit(self)
	emit_signal("send_hit", hurtbox) 
