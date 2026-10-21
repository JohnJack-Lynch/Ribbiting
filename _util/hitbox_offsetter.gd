class_name HitboxOffsetter
extends Marker2D

@export var initial_position : Vector2

@export var coll : CollisionShape2D
@export var reference : Node
@export var hitbox : Hitbox2D

func _ready() -> void:
	position = initial_position
	#untouched_pos = initial_position
	
	if reference is SpriteFlipper2D:
		reference.update_direction.connect(_on_update_direction)

func _physics_process(delta: float) -> void:
	coll.position = position

func _on_update_direction(facing_left : bool) -> void:
	if facing_left:
		position.x = -initial_position.x
		hitbox.set_hit_direction(0)
	else:
		position.x = abs(initial_position.x)
		hitbox.set_hit_direction(2)
