@icon("res://Assets/Icons/ico_edr_state.png")
class_name State
extends Node

@export var animation_name : String

var char : CharacterBody2D
var anim : AnimationPlayer
var sm : StateMachine

signal interupt_state(new_state : State)

func enter() -> void:
	#print(name)
	anim.play(animation_name)

func exit() -> void:
	pass

func s_physics(delta : float) -> State:
	return null

func s_input(event : InputEvent) -> State:
	return null

func s_draw(delta : float) -> State:
	return null
