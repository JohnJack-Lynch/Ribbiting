class_name MapNode
extends Node2D

@export var world_data : WorldData
@export var locked : bool

var completed : bool = false

var fly_1_collected : bool = false
var fly_2_collected : bool = false
var fly_3_collected : bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_2d.texture = world_data.map_texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	point_light_2d.enabled = !locked
