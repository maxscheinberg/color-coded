extends Node2D

@export var col: Color = Color.WHITE
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var mat: ShaderMaterial = sprite.material

var moving: bool = false
var invalid_feedback_playing: bool = false
var is_greyscale: bool = true

func _ready() -> void:
	sprite.self_modulate = GameColors.canonical(col)
	anim.get_animation("Look Left").loop_mode = Animation.LOOP_NONE
	anim.get_animation("Look Right").loop_mode = Animation.LOOP_NONE
	anim.get_animation("Blink").loop_mode = Animation.LOOP_NONE

func get_color() -> Color:
	return sprite.get_self_modulate()

func set_color(col: Color) -> void:
	self.col = GameColors.canonical(col)
	sprite.self_modulate = self.col
	get_tree().call_group("uwpc", "update_with_player", self)

func play_invalid_feedback(source_pos: Vector2) -> void:
	if invalid_feedback_playing:
		return

	invalid_feedback_playing = true

	var original_pos: Vector2 = position
	var dir: Vector2 = (global_position - source_pos).normalized()

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
	
func toggle_greyscale() -> void:
	is_greyscale = not is_greyscale
	mat.set_shader_parameter("greyscale_enabled", is_greyscale)
