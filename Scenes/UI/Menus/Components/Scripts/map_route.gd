@tool
class_name MapRoute
extends Path2D

#@export var point_a : MapNode
#@export var point_b : MapNode

@export var enabled : bool = false

@export_tool_button("Refresh Path Visual") var refresh_button = refresh_path_vis

@export_group("Visual Effects")
@export_color_no_alpha var enable_color : Color
@export_color_no_alpha var disable_color : Color

@export_group("Object References")
@export var line : Line2D
@export var drop_shadow : Line2D

var follow : PathFollow2D
var r_transform : RemoteTransform2D

var tween : Tween

var flip_traversal : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	if !Engine.is_editor_hint():
		refresh_path_vis()
		
		follow = PathFollow2D.new()
		
		r_transform = RemoteTransform2D.new()
		r_transform.update_rotation = false
		
		add_child(follow)
		follow.add_child(r_transform)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func refresh_path_vis() -> void:
	line.points = curve.get_baked_points()
	drop_shadow.points = curve.get_baked_points()
	
	if enabled:
		line.default_color = enable_color
	else:
		line.default_color = disable_color

func move_player_along_route() -> void:
	if tween:
		tween.kill()
	
	
