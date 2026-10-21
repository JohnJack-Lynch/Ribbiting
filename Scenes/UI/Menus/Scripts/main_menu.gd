class_name MainMenu
extends Control

var start_tween : Tween

@onready var confirm_snd: AudioStreamPlayer = $ConfirmSnd

func _ready() -> void:
	Fader.animation_player.play("WipeOut")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		Fader.animation_player.play("WipeIn")
		await Fader.animation_player.animation_finished
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/game.tscn")
