class_name Switch
extends Area2D

@export var pressure_senstive : bool = false

@export var light : PointLight2D

var pressed : bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var press_snd: AudioStreamPlayer2D = $PressSnd

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_press)
	body_exited.connect(_on_release)

func _process(delta: float) -> void:
	if pressed == true:
		if pressure_senstive:
			sprite_2d.frame = 3
		else:
			sprite_2d.frame = 1
		
		if light:
			light.enabled = true
	else:
		if pressure_senstive:
			sprite_2d.frame = 2
		else:
			sprite_2d.frame = 0
		
		if light:
			light.enabled = false

func press(on : bool) -> void:
	pressed = on
	press_snd.play()
	print("pressed")


func _on_press(body : Node2D) -> void:
	if body:
		if body is Player:
			if body.spr_pos_tween:
				await body.spr_pos_tween.finished
			press(true)
			#pressed = true
			#press_snd.play()
			#print("pressed")

func _on_release(body : Node2D) -> void:
	if body is Player:
		if pressure_senstive:
			
			if body.spr_pos_tween:
				await body.spr_pos_tween.finished
			
			press(false)
			#pressed = false
			#
			#press_snd.play()
			#print("unpressed")
