class_name MapCam
extends Camera2D

@export var zoom_time : float = 1.0
@export var target : Node2D

var zoom_tween : Tween

signal force_zoom(new_zoom : Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		position.y = target.position.y

func zoom_cam(new_zoom : Vector2) -> void:
	if zoom_tween:
		zoom_tween.kill()
	
	zoom_tween = create_tween()
	
	zoom_tween.tween_property(self, "zoom", new_zoom, zoom_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
