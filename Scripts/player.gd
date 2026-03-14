extends CharacterBody2D

@export var col: Color
@onready var anim: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var moving = false
var input_dir : Vector2 = Vector2.ZERO
enum { LEFT, RIGHT, UP, DOWN}

func _ready():
	set_color(col)
	anim.get_animation("Look Left").loop_mode = Animation.LOOP_NONE
	anim.get_animation("Look Right").loop_mode = Animation.LOOP_NONE
	
func get_color() -> Color:
	return sprite.get_self_modulate()

func set_color(col: Color) -> void:
	sprite.self_modulate = col
	get_tree().call_group("uwpc", "update_with_player", self)
