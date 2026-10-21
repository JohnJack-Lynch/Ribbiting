extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func set_iris_pos(pos : Vector2) -> void:
	pass

#var scene_to_load : String
#var fade_tween : Tween
#
#func switch_scene(path : String) -> void:
	#if fade_tween:
		#fade_tween.kill()
	#
	#scene_to_load = path
	#get_tree().paused = true
	#
	#fade_tween = create_tween().set_trans(Tween.TRANS_SINE)
	#fade_tween.tween_property(color_rect, "modulate:a", 1.0, 0.2).connect("finished", _on_tween_finished)
	#fade_tween.chain().tween_property(color_rect, "modulate:a", 0, 0.4)
#
#func _on_tween_finished() -> void:
	#get_tree().paused = false
	#get_tree().call_deferred("change_scene_to_file", scene_to_load)
