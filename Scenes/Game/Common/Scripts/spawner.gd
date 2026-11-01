@tool
class_name Spawner
extends Marker2D

enum FrogVariant {
	BASIC,
	MEAN
}

#@export var frog_data : FrogData
@export var frog_variant : FrogVariant #:
	#set(value):
		#frog_variant = value
		#
		#match value:
			#FrogVariant.BASIC:
				#target_uid = BASIC_FROG_UID
			#FrogVariant.MEAN:
				#target_uid = MEAN_FROG_UID
@export var set_active : bool

@export var frog_textures : Array[AtlasTexture]

var target_uid : String = ""

const BASIC_FROG_UID : String = "uid://5ull6trhjdm7"
const MEAN_FROG_UID : String = "uid://cnkknyhx6gmle"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
