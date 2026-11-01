@tool
class_name Blockade
extends Node2D

enum Orientation {
	HORIZONTAL,
	VERTICAL
}

@export var block : PackedScene
@export var poof : PackedScene
@export var blockade_direction : Orientation
@export var blockade_length : int = 0

@export_tool_button("Set Blocks") var set_blocks_button = create_blockade

@export var flip_collision : bool = false
@export var layer : int = 1
@export var mask : int = 1

var block_list : Array

const TILE_SIZE : Vector2 = Vector2(16,16)
const BLOCK_OFFSET : Vector2 = Vector2(8,8)


func _get_configuration_warnings() -> PackedStringArray:
	if !block:
		return ["Please assign a PackedScene to block."]
	else:
		return []

func _ready() -> void:
	set_blockade_collision(true)

func set_blockade_collision(on : bool) -> void:
	for c in get_children():
		#if c is not AnimatedSprite2D:
		if flip_collision == true:
			c.visible = !on
			c.set_collision_layer_value(layer, !on)
			c.set_collision_mask_value(mask, !on)
		else:
			c.visible = on
			c.set_collision_layer_value(layer, on)
			c.set_collision_mask_value(mask, on)
		#elif c is AnimatedSprite2D:
			#c.play("default")

func create_blockade() -> void:
	for c in get_children():
		c.free()
	
	
	for i in range(blockade_length):
		var inst = block.instantiate()
		#var poof_inst = poof.instantiate()
		
		add_child(inst)
		#add_child(poof_inst)
		
		inst.owner = get_tree().edited_scene_root
		#poof_inst.owner = get_tree().edited_scene_root
		
		if blockade_direction == Orientation.HORIZONTAL:
			inst.global_position = global_position + ((Vector2(float(i), 0) * TILE_SIZE) + BLOCK_OFFSET)
			#poof_inst.position = (Vector2(float(i), 0) * TILE_SIZE) + BLOCK_OFFSET
		
		if blockade_direction == Orientation.VERTICAL:
			inst.global_position = global_position + ((Vector2(0, float(i)) * TILE_SIZE) + BLOCK_OFFSET)
			#poof_inst.position = (Vector2(0, float(i)) * TILE_SIZE) + BLOCK_OFFSET
		
	
	
