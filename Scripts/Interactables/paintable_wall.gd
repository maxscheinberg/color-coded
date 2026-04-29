extends Node2D

# A neutral wall that can be painted by the brush pickup.
# Once painted, it behaves exactly like a ColorWall —
# only a player whose color matches can pass through.
# Before being painted it is white/neutral and always blocks.

@onready var rect: ColorRect = $ColorRect

# Neutral color shown before any paint is applied
#changed to white for consistency mixing logic would work just fine here
const NEUTRAL_COLOR := Color(1.0, 1.0, 1.0, 1.0)

@export var painted_color: Color = Color.TRANSPARENT   # invalid = unpainted
@export var is_painted: bool = false

func _ready() -> void:
	_sync_visual_state()

# --- Brush API ----------------------------------------------------------

## Returns true if this wall can be painted by this color.
func is_paintable(color: Color = Color.TRANSPARENT) -> bool:
	if not is_painted:
		return true

	if GameColors.match(color, Color.TRANSPARENT):
		return false

	return GameColors.can_mix_primaries(color, painted_color)

## Called by the brush when the player uses it adjacent to this wall.
func apply_paint(color: Color) -> bool:
	if not is_paintable(color):
		return false

	painted_color = _get_painted_color(color)
	is_painted = true
	rect.color = painted_color
	_play_paint_feedback()
	return true

## Called by undo — restores the wall to its neutral, unpainted state.
func set_color(color: Color) -> void:
	if GameColors.match(color, NEUTRAL_COLOR):
		# Undo painted → neutral
		painted_color = Color.TRANSPARENT
		is_painted = false
		rect.color = NEUTRAL_COLOR
	else:
		painted_color = GameColors.canonical(color)
		is_painted = true
		rect.color = painted_color

func get_color() -> Color:
	return painted_color if is_painted else NEUTRAL_COLOR

# --- Level system API ---------------------------------------------------

func can_move_here(player) -> bool:
	if not is_painted:
		return false   # unpainted wall always blocks
	return GameColors.match(player.get_color(), painted_color)

# --- Visual feedback ----------------------------------------------------

func _play_paint_feedback() -> void:
	var original_scale := rect.scale
	var tween := create_tween()
	tween.tween_property(rect, "scale", Vector2(1.08, 1.08), 0.06)
	tween.tween_property(rect, "scale", original_scale, 0.10)

func _get_painted_color(color: Color) -> Color:
	var paint_color: Color = GameColors.canonical(color)
	if not is_painted:
		return paint_color
	return GameColors.mix_primaries(paint_color, painted_color)

func _sync_visual_state() -> void:
	if is_painted and not GameColors.match(painted_color, Color.TRANSPARENT):
		painted_color = GameColors.canonical(painted_color)
		rect.color = painted_color
	else:
		painted_color = Color.TRANSPARENT
		is_painted = false
		rect.color = NEUTRAL_COLOR
