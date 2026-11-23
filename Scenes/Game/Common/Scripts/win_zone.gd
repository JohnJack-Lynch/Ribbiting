class_name WinZone
extends Area2D

func _ready() -> void:
	SignalBus.reenable_node.connect(_on_reenable)

func _on_reenable(game_state : int) -> void:
	match game_state:
		0:
			hide()
			set_deferred("monitoring", false)
		1:
			show()
			set_deferred("monitoring", true)
