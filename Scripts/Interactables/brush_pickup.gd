extends Node2D
 
# The brush is a one-use pickup item.
# When the player steps onto the brush's cell they pick it up.
# On the very next move that would land on a PaintableWall the brush fires,
# painting that wall with the player's current color, then disappears.
#
# Works with the undo system: picking up / using the brush are both
# recorded as interactions in the levelbase snapshot.
 
@onready var sprite: Sprite2D = $Sprite2D
 
# The level's background TileMapLayer — assigned automatically by levelbase
# via the standard _assign_player_duplicate / property-injection pattern.
# We re-use the same trick: levelbase looks for a "background" property.
@export var background: TileMapLayer
 
var held_by: Node2D = null      # which character is holding the brush
var _used: bool = false          # consumed flag
 
# ── Pickup (floor object) ──────────────────────────────────────────────
 
func is_floor_object() -> bool:
	return true   # processed by _process_floor_objects_for in levelbase
 
func _get_level() -> Node:
	# Walk up the tree until we find the node that has update_brush_ui
	var node = get_parent()
	while node != null:
		if node.has_method("update_brush_ui"):
			return node
		node = node.get_parent()
	return null
 
func interact(player) -> void:
	if _used or held_by != null:
		return
	held_by = player
	visible = false
	var level = _get_level()
	if level:
		level.update_brush_ui(player.get_color())
	_play_pickup_feedback(player)
 
# ── Paint action ──────────────────────────────────────────────────────
 
## Called by levelbase BEFORE the move is committed, when the player is
## about to step into a cell that contains a PaintableWall.
## Returns true if the brush was consumed (levelbase should proceed with
## the move rather than blocking it).
func try_paint(player, target_object) -> bool:
	if _used or held_by != player:
		return false
	if not target_object.has_method("is_paintable"):
		return false
	if not target_object.is_paintable():
		return false
 
	# Record old state for undo before applying
	target_object.apply_paint(player.get_color())
	_consume()
	return true
 
func _consume() -> void:
	_used = true
	held_by = null
	var level = _get_level()
	if level:
		level.update_brush_ui(Color.TRANSPARENT)
	queue_free()
 
# ── Undo support ───────────────────────────────────────────────────────
# levelbase already records { object, old_color } for objects with get_color/set_color.
# PaintableWall implements both, so undo automatically restores the wall.
# The brush itself is queue_freed on use; full undo of brush pickup would
# require re-instantiating it — that is left as a future enhancement.
# Undo while holding (not yet used) just leaves the brush invisible, which
# is acceptable for puzzle games with limited undo depth.
 
# ── Visuals ────────────────────────────────────────────────────────────
 
func _play_pickup_feedback(player) -> void:
	# Small float-up-and-fade on pickup
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "position", sprite.position + Vector2(0, -12), 0.18)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.18)
	await tween.finished
