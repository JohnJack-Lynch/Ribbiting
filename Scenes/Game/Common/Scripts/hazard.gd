class_name Hazard
extends Area2D

@onready var kill_snd: AudioStreamPlayer2D = $KillSnd
@onready var poof: AnimatedSprite2D = $Poof

func _ready() -> void:
	body_entered.connect(_on_player_contact)

func _on_player_contact(body : Node2D) -> void:
	if body is Player:
		await body.spr_pos_tween.finished
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
		
		
