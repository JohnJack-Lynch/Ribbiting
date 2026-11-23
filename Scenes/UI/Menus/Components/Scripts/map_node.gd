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

var camera : MapCam

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var area_2d: Area2D = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Engine.is_editor_hint():
		level_bubble.visible = false
		if level_data:
			#level_bubble.visible = true
			
			level_bubble.set_label_text(level_data.level_name, level_data.level_number, level_data.world_number)
		#else:
			#level_bubble.visible = false
		
		camera = get_tree().get_first_node_in_group("Camera")
	
	SignalBus.reenable_node.connect(_on_reenable)
	
	cursor_check.body_entered.connect(_on_frog_entered)
	cursor_check.body_exited.connect(_on_frog_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#point_light_2d.enabled = !locked
	
	pass

func refresh_node() -> void:
	pass


func _on_frog_entered(body : Node2D) -> void:
	print("frog entered")
	
	cur_node = true
	
	if body is MapPlayer:
		body.cur_map_node = self
		
		print(body.cur_map_node)
	
	#camera.force_zoom.emit()
	camera.zoom_cam(Vector2(1.5, 1.5))
	level_bubble.anim.play("PopIn")

func _on_frog_exited(body : Node2D) -> void:
	print("frog exited")
	
	cur_node = false
	
	if body is MapPlayer:
		body.cur_map_node = null
		
		print(body.cur_map_node)
	
	#camera.force_zoom.emit()
	camera.zoom_cam(Vector2.ONE)
	level_bubble.anim.play("PopOut")

func _on_reenable(game_state : int) -> void:
	if game_state == 0:
		print("reenabled " + name)
		
		area_2d.set_deferred("monitoring", true)
	else:
		print("disabled map node " + name)
		area_2d.set_deferred("monitoring", false)
