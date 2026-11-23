class_name MapPlayer
extends CharacterBody2D

enum NavStates {
	MOVE,
	HOVER
}

@export var entry_state : NavStates

@export var tween_time : float = 0.185

@export var camera : MapCam

@export_group("Object References")
@export var anim : AnimationPlayer
@export var sprite : Sprite2D
@export var buffer_box : Area2D

var on_node : bool = false

var cur_map_node : MapNode

var state : NavStates

var spr_pos_tween : Tween

const TILE_SIZE : Vector2 = Vector2(16,16)

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var up_cast: RayCast2D = $UpCast
@onready var right_cast: RayCast2D = $RightCast
@onready var down_cast: RayCast2D = $DownCast
@onready var left_cast: RayCast2D = $LeftCast

@onready var hop_snd: AudioStreamPlayer2D = $HopSnd
@onready var croak_snd: AudioStreamPlayer2D = $CroakSnd

func _ready() -> void:
	SignalBus.reenable_node.connect(_on_reenable)

func _physics_process(delta: float) -> void:
	match state:
		NavStates.MOVE:
			if !spr_pos_tween or !spr_pos_tween.is_running():
				if Input.is_action_just_pressed("RIB_UP") and up_cast.is_colliding() == false:
					movement(Vector2.UP)
				elif Input.is_action_just_pressed("RIB_RIGHT") and right_cast.is_colliding() == false:
					sprite.flip_h = false
					
					movement(Vector2.RIGHT)
				elif Input.is_action_just_pressed("RIB_DOWN") and down_cast.is_colliding() == false:
					movement(Vector2.DOWN)
				elif Input.is_action_just_pressed("RIB_LEFT") and left_cast.is_colliding() == false:
					sprite.flip_h = true
					
					movement(Vector2.LEFT)
				else:
					anim.play("Idle")
		NavStates.HOVER:
			pass

func _unhandled_input(event: InputEvent) -> void:
	if cur_map_node != null:
		if Input.is_action_just_pressed("RIB_CROAK"):
			switch_state(NavStates.HOVER)
			anim.play("Croak")
			#await anim.animation_finished
			
			SignalBus.go_to_level.emit(cur_map_node.level_data.level_uid)

func switch_state(new_state : NavStates) -> void:
	state = new_state

func movement(dir : Vector2) -> void:
	#var buffer_box_check# := buffer_box.get_overlapping_areas()
	
	
	#buffer_box_check = buffer_box.get_overlapping_areas()
	
	buffer_box.global_position += dir * TILE_SIZE
	
	#print(buffer_box.area_entered)
	#print(buffer_box.body_entered)
	#
	#print(global_position)
	#print(buffer_box.global_position)
	
	await get_tree().physics_frame
	
	if check_next_tile() == true:
		if spr_pos_tween:
			spr_pos_tween.kill()
		
		# keep the player sprite in place so it can be tweened
		
		#if is_mean == true:
			#global_position += -(dir * TILE_SIZE)
			#sprite.global_position -= -(dir * TILE_SIZE)
		#else:
			#global_position += dir * TILE_SIZE
			#sprite.global_position -= dir * TILE_SIZE
		
		global_position += dir * TILE_SIZE
		sprite.global_position -= dir * TILE_SIZE
		
		anim.play("Hop")
		hop_snd.play()
		spr_pos_tween = create_tween()
		spr_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		spr_pos_tween.tween_property(sprite, "global_position", global_position, tween_time).set_trans(Tween.TRANS_SINE)
		
		#print(global_position)
	
	if spr_pos_tween:
		await spr_pos_tween.finished
	
	buffer_box.global_position = global_position

func check_next_tile() -> bool: # checks to see if the targeted tile will be occupied by another frog
	# if true, self moves
	# if false, other frog(s) move
	var buffer_box_check := buffer_box.get_overlapping_areas()
	
	
	
	if buffer_box_check == []:
		return true
	
	for b in buffer_box_check:
		if b == self:
			continue
		
		if b.get_parent() is Player:
			var frog : Player = b.get_parent()
			
			if frog.priority > self.priority:
				return false
				break
	
	return true

func set_processes(enabled : bool) -> void:
	print("processes set")
	set_process(enabled)
	set_physics_process(enabled)


func _on_reenable(game_state : int) -> void:
	if game_state == 0:
		print("reenabled " + name)
		process_mode = Node.PROCESS_MODE_INHERIT
		switch_state(NavStates.MOVE)
		show()
