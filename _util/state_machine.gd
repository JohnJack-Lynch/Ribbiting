@icon("res://Assets/Icons/ico_edr_state_machn.png")
class_name StateMachine
extends Node

@export var initial_state : State

var cur_state : State
var prev_state : State

func sm_ready(char : CharacterBody2D, anim : AnimationPlayer) -> void: # initializes the state machine, stand-in for the "_ready()" function
	for child in get_children(): # gives each child state a reference to the parent object (player, enemy, etc.)
		if child is State:
			child.char = char
			child.anim = anim
			child.sm = self
			child.interupt_state.connect(_on_interupt_state.bind())
	
	change_state(initial_state)

func change_state(new_state : State) -> void:
	prev_state = cur_state
	
	if cur_state:
		cur_state.exit()
	
	cur_state = new_state
	cur_state.enter()

# stand-ins for several functions to be called by the player
func sm_physics(delta : float) -> void: # _physics_process()
	var new_state = cur_state.s_physics(delta)
	
	if new_state:
		change_state(new_state)

func sm_input(event : InputEvent) -> void: # _unhandled_input()
	var new_state = cur_state.s_input(event)
	
	if new_state:
		change_state(new_state)

func sm_draw(delta : float) -> void: # _process()
	var new_state = cur_state.s_draw(delta)
	
	if new_state:
		change_state(new_state) 

func _on_interupt_state(new_state : State) -> void:
	change_state(new_state)
