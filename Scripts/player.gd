extends CharacterBody2D

@export var col: Color
@onready var anim: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var moving = false
var input_dir : Vector2 = Vector2.ZERO
var invalid_feedback_playing: bool = false

enum { LEFT, RIGHT, UP, DOWN }

func _ready():
	set_color(col)
	anim.get_animation("Look Left").loop_mode = Animation.LOOP_NONE
	anim.get_animation("Look Right").loop_mode = Animation.LOOP_NONE
	anim.get_animation("Blink").loop_mode = Animation.LOOP_NONE
	
func get_color() -> Color:
	return sprite.get_self_modulate()

func is_white() -> bool:
	return GameColors.match(get_color(), GameColors.WHITE)

func set_color(col: Color) -> void:
	sprite.self_modulate = GameColors.canonical(col)
	get_tree().call_group("uwpc", "update_with_player", self)

func play_invalid_feedback(source_pos: Vector2) -> void:
	if invalid_feedback_playing:
		return

	invalid_feedback_playing = true

	var original_pos: Vector2 = position
	var dir: Vector2 = (global_position - source_pos).normalized()

	# fallback in case both positions are the same
	if dir == Vector2.ZERO:
		dir = Vector2(0, -1)

	var recoil: Vector2 = dir * 6.0

	var tween := create_tween()
	tween.tween_property(self, "position", original_pos + recoil, 0.05)
	tween.tween_property(self, "position", original_pos, 0.07)

	await tween.finished
	position = original_pos
	invalid_feedback_playing = false

func play_valid_feedback() -> void:
	var original_scale: Vector2 = scale
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.12, 1.12), 0.08)
	tween.tween_property(self, "scale", original_scale, 0.10)
