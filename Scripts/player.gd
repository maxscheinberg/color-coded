extends CharacterBody2D

@export var col: Color
@onready var anim: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var blocked_sfx: AudioStreamPlayer = $BlockedSfx
@onready var color_change_sfx: AudioStreamPlayer = $ColorChangeSfx

var moving = false
var input_dir : Vector2 = Vector2.ZERO
var invalid_feedback_playing: bool = false
var _current_color: Color = Color.TRANSPARENT
var _initialized: bool = false

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


#added tiny tween when trasitioning color
func set_color(col: Color) -> void:
	var new_color := GameColors.canonical(col)
	if _initialized:
		color_change_sfx.play()
	else:
		_initialized = true
	_current_color = new_color
	var tween := create_tween()
	tween.tween_property(sprite, "self_modulate", new_color, 0.08)
	
func play_invalid_feedback(source_pos: Vector2) -> void:
	blocked_sfx.play()
	if invalid_feedback_playing:
		return

	invalid_feedback_playing = true

	var original_pos: Vector2 = position
	var original_scale: Vector2 = scale
	var dir: Vector2 = (global_position - source_pos).normalized()

	if dir == Vector2.ZERO:
		dir = Vector2(0, -1)

	var recoil: Vector2 = dir * 6.0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", original_pos + recoil, 0.05)
	tween.tween_property(self, "scale", Vector2(0.85, 0.85), 0.05)
	tween.chain().tween_property(self, "position", original_pos, 0.07)
	tween.chain().tween_property(self, "scale", original_scale, 0.07)

	await tween.finished
	position = original_pos
	scale = original_scale
	invalid_feedback_playing = false
	
	
func play_valid_feedback() -> void:
	var original_scale: Vector2 = scale
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.12, 1.12), 0.08)
	tween.tween_property(self, "scale", original_scale, 0.10)
