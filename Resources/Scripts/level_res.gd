class_name LevelData
extends Resource

enum PlayerFrogMode {
	BASIC,
	MEAN
}

@export var player_frog : PlayerFrogMode
@export var player_spawn : Vector2
@export var win_zone_pos : Vector2

@export var camera_pos : Vector2 = Vector2(96.0, 72.0)
@export var camera_zoom : Vector2 = Vector2.ONE
