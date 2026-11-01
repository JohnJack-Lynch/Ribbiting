class_name Player
extends CharacterBody2D

enum States {
	ACTIVE,
	CROAK,
	SNOOZE,
	WIN
}

#enum FrogMode {
	#BASIC,
	#MEAN
#}

#@export var mode : FrogMode
@export var is_mean : bool = false
@export var active : bool = false

@export_group("Overrides")
@export var entry_state : States
@export var hop_dist : int = 1
@export var override_priority : int
@export var tween_time : float = 0.185

@export_group("Object References")
@export var echo_effect : PackedScene


@export var anim : AnimationPlayer
@export var sprite : Sprite2D
@export var spr_flip : SpriteFlipper2D
@export var buffer_box : Area2D
@export var croak_box : Area2D
@export var blink_timer : Timer

var priority : int = 0

var croak_active : bool = false
var awoken : bool = false

var state : States

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
	if active == false:
		switch_state(States.SNOOZE)
	else:
		add_to_group("ActiveFrog")
	
	#croak_box.set_deferred("monitoring", false)
	
	anim.animation_finished.connect(_on_anim_finished)
	
	if override_priority != 0:
		priority = override_priority
	
	#SignalBus.level_complete.connect(_on_level_complete)
	#croak_box.area_entered.connect(_on_detect_switch)

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	croak_box.visible = active
	
	match state:
		States.ACTIVE:
			active = true
			
			awoken = false
			
			if is_mean:
				if !spr_pos_tween or !spr_pos_tween.is_running():
					if Input.is_action_just_pressed("RIB_UP") and down_cast.is_colliding() == false:
						
						
						
						movement(Vector2.DOWN)
					elif Input.is_action_just_pressed("RIB_RIGHT") and left_cast.is_colliding() == false:
						if is_mean:
							sprite.flip_h = true
						else:
							sprite.flip_h = false
						
						movement(Vector2.LEFT)
					elif Input.is_action_just_pressed("RIB_DOWN") and up_cast.is_colliding() == false:
						
						
						movement(Vector2.UP)
					elif Input.is_action_just_pressed("RIB_LEFT") and right_cast.is_colliding() == false:
						if is_mean:
							sprite.flip_h = false
						else:
							sprite.flip_h = true
						
						movement(Vector2.RIGHT)
					else:
						anim.play("Idle")
			else:
				if !spr_pos_tween or !spr_pos_tween.is_running():
					if Input.is_action_just_pressed("RIB_UP") and up_cast.is_colliding() == false:
						
						
						
						movement(Vector2.UP)
					elif Input.is_action_just_pressed("RIB_RIGHT") and right_cast.is_colliding() == false:
						if is_mean:
							sprite.flip_h = true
						else:
							sprite.flip_h = false
						
						movement(Vector2.RIGHT)
					elif Input.is_action_just_pressed("RIB_DOWN") and down_cast.is_colliding() == false:
						
						
						movement(Vector2.DOWN)
					elif Input.is_action_just_pressed("RIB_LEFT") and left_cast.is_colliding() == false:
						if is_mean:
							sprite.flip_h = false
						else:
							sprite.flip_h = true
						
						movement(Vector2.LEFT)
					else:
						anim.play("Idle")
			
			if Input.is_action_just_pressed("RIB_CROAK"):
				switch_state(States.CROAK)
			
			
		States.CROAK:
			if croak_active == false:
				croak()
				frog_check()
				switch_check()
				croak_active = true
			#frog_check()
		States.SNOOZE:
			active = false
			
			if awoken == false:
				anim.play("Snooze")
		States.WIN:
			pass
	
	#if active == true:
		#if !spr_pos_tween or !spr_pos_tween.is_running():
			#if Input.is_action_just_pressed("RIB_UP") and up_cast.is_colliding() == false:
				#movement(Vector2.UP)
			#elif Input.is_action_just_pressed("RIB_RIGHT") and right_cast.is_colliding() == false:
				#movement(Vector2.RIGHT)
			#elif Input.is_action_just_pressed("RIB_DOWN") and down_cast.is_colliding() == false:
				#movement(Vector2.DOWN)
			#elif Input.is_action_just_pressed("RIB_LEFT") and left_cast.is_colliding() == false:
				#movement(Vector2.LEFT)
		#
		#if Input.is_action_just_pressed("RIB_CROAK"):
			#print("croak")
			#croak()
		#
		#
	
	move_and_slide()

func switch_state(new_state : States) -> void:
	state = new_state
	
	if new_state == States.SNOOZE:
		remove_from_group("ActiveFrog")
	else:
		if !is_in_group("ActiveFrog"):
			add_to_group("ActiveFrog")
	
	if is_in_group("ActiveFrog"):
		print("In group : ActiveFrog")
	else:
		print("Not in group : ActiveFrog")

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
	
	print(check_next_tile())
	
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
	
	
	
	print(buffer_box_check)
	
	
	
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

func croak() -> void:
	print("croak func")
	anim.play("Croak")
	croak_snd.play()

func frog_check() -> void:
	var frogs_found := croak_box.get_overlapping_bodies()
	var frogs_detected : bool = false
	
	print(frogs_found)
	
	if frogs_found == []:
		return
	
	for f in frogs_found:
		if f == self or f.active == true:
			print("cannot wake up " + f.name)
			continue
		
		#if f is Player and f.state == States.ACTIVE:
			#
			#continue
		
		#if f is Switch:
			#if f.pressed == false:
				#f.press(true)
				#continue
			#else:
				#continue
		
		if f is Player:
			
			
			f.awoken = true
			f.anim.play("WakeUp")
			frogs_detected = true
		
	if frogs_detected == true:
		active = false

func switch_check() -> void:
	var switches_found := croak_box.get_overlapping_areas()
	var switches_detected : bool = false
	
	print(switches_found)
	
	for s in switches_found:
		if s is Switch:
			if s.pressed == false:
				s.press(true)

func spawn_ring() -> void:
	var ring_inst = echo_effect.instantiate()
	
	ring_inst.global_position = global_position
	
	get_parent().add_child(ring_inst)
	

func _on_anim_finished(anim_name : StringName) -> void:
	if anim_name == "Croak":
		print("croak finished")
		if active == false:
			switch_state(States.SNOOZE)
		else:
			#anim.play("Idle")
			switch_state(States.ACTIVE)
			
		
		croak_active = false
		
		SignalBus.refresh_frog_count.emit()

#func _on_level_complete() -> void:
	#set_physics_process(false)

#func _on_detect_switch(area : Area2D) -> void:
		#if area is Switch:
			#print("found switch")
			#if area.pressed == false:# and croak_active == true:
				#
				#area.press(true)
