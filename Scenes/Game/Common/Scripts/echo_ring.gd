class_name EchoRing
extends Node2D

@export var starting_rot : float = 200.0

var rotate_spd : float

var tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotate_spd = starting_rot
	tween_in()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_spd = rotate_spd/1.1
	
	#if rotate_spd < 20.0:
		#rotate_spd = 20.0
	
	rotation += rotate_spd * delta

func tween_in() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "scale", Vector2(1.98,1.98), 0.7).set_trans(Tween.TRANS_QUINT)
	
	await tween.finished
	
	tween_out()


func tween_out() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.5).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	
	queue_free()
