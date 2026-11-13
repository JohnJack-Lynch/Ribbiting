@tool
class_name MapNode
extends Node2D

@export var level_data : MapData
@export var locked : bool

@export_tool_button("Set World Data") var refresh_button = refresh_node

@export_group("Connections")
@export var can_move_up : bool
@export var can_move_right : bool
@export var can_move_down : bool
@export var can_move_left : bool

@export_subgroup("Connection Refs")
@export var u_path : MapRoute
@export var r_path : MapRoute
@export var d_path : MapRoute
@export var l_path : MapRoute

@export_group("Object References")
@export var cursor_check : Area2D
@export var level_bubble : LevelBubble

var completed : bool = false

var cur_node : bool = false
var target_path : MapRoute

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#level_bubble.visible = false
	
	if !Engine.is_editor_hint():
		if level_data:
			level_bubble.visible = true
			
			level_bubble.set_label_text(level_data.level_name, level_data.level_number, level_data.world_number)
		else:
			level_bubble.visible = false
		
		cursor_check.area_entered.connect(_on_frog_entered)
		cursor_check.area_exited.connect(_on_frog_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#point_light_2d.enabled = !locked
	
	pass

func refresh_node() -> void:
	pass


func _on_frog_entered(area : Area2D) -> void:
	pass

func _on_frog_exited(area : Area2D) -> void:
	pass
