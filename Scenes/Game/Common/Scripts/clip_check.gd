class_name ClipCheck
extends Area2D

@export var poof : AnimatedSprite2D
@export var kill_snd : AudioStreamPlayer2D

@onready var l_offset : Vector2 = global_position + Vector2(-16.0, 0.0)
@onready var u_offset : Vector2 = global_position + Vector2(0.0, -16.0)
@onready var r_offset : Vector2 = global_position + Vector2(16.0, 0.0)
@onready var d_offset : Vector2 = global_position + Vector2(0.0, 16.0)

@onready var up_cast: RayCast2D = $UpCast
@onready var right_cast: RayCast2D = $RightCast
@onready var down_cast: RayCast2D = $DownCast
@onready var left_cast: RayCast2D = $LeftCast

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(l_offset)
	print(u_offset)
	print(r_offset)
	print(d_offset)
	
	body_entered.connect(_on_player_clip)

func get_open_side() -> Vector2:
	if up_cast.is_colliding() == false:
		return u_offset
	
	if right_cast.is_colliding() == false:
		return r_offset
	
	if down_cast.is_colliding() == false:
		return d_offset
	
	if left_cast.is_colliding() == false:
		return l_offset
	
	return Vector2.ZERO

func kill_frog(body : Player) -> void:
	body.visible = false
	body.set_physics_process(false)
	body.collision_shape_2d.disabled = true
	
	poof.visible = true
	poof.play("default")
	kill_snd.play()
	await poof.animation_finished
	
	body.remove_from_group("ActiveFrog")
	SignalBus.refresh_frog_count.emit()
	body.queue_free()


func _on_player_clip(body : Node2D) -> void:
	if body is Player:
		
		if get_open_side() == Vector2.ZERO:
			kill_frog(body)
		else:
			print(get_open_side())
