extends Node2D

# A neutral wall that can be painted by the brush pickup.
# Once painted, it behaves exactly like a ColorWall —
# only a player whose color matches can pass through.
# Before being painted it is white/neutral and always blocks.

@onready var rect: ColorRect = $ColorRect

# Neutral color shown before any paint is applied
const NEUTRAL_COLOR := Color(0.85, 0.85, 0.85, 1.0)

var painted_color: Color = Color.TRANSPARENT   # invalid = unpainted
var is_painted: bool = false

func _ready() -> void:
	rect.color = NEUTRAL_COLOR

# --- Brush API ----------------------------------------------------------

## Returns true if this wall can still be painted (not yet painted).
func is_paintable() -> bool:
	return not is_painted

## Called by the brush when the player uses it adjacent to this wall.
func apply_paint(color: Color) -> void:
	if not is_paintable():
		return
	painted_color = GameColors.canonical(color)
	is_painted = true
	rect.color = painted_color
	_play_paint_feedback()

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
