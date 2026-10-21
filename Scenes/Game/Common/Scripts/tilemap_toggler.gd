class_name TilemapToggler
extends Node

@export var base_tilemap : TileMapLayer
@export var target_tilemap : TileMapLayer
@export var trigger : Switch

@onready var toggle_snd: AudioStreamPlayer2D = $ToggleSnd

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_tilemap.enabled = true
	target_tilemap.enabled = false
	
	trigger.body_entered.connect(_on_trigger_activated)
	trigger.body_exited.connect(_on_trigger_deactivated)


func _on_trigger_activated(body : Node2D) -> void:
	if body is Player:
		toggle_snd.play()
		
		base_tilemap.enabled = false
		target_tilemap.enabled = true

func _on_trigger_deactivated(body :Node2D) -> void:
	if trigger.pressure_senstive:
		if body is Player:
			toggle_snd.play()
			
			base_tilemap.enabled = true
			target_tilemap.enabled = false
