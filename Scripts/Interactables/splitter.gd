extends Node2D

@export var new_pos1: Vector2
@export var new_pos2: Vector2
@export var player_color: Color
@export var duplicate_color: Color
@export var player_duplicate: Node2D

func is_floor_object() -> bool:
	return true

func interact(player) -> void:
	player.moving = true
	if player_duplicate == null:
		player_duplicate = _resolve_player_duplicate()

	if player_duplicate == null or player_duplicate.visible:
		return
	
	player_duplicate.scale = Vector2(0.05, 0.05)
	var tween = create_tween()
	tween.tween_property(player, "scale", Vector2(0.05, 0.05), 0.4)
	await tween.finished
	
	player.set_color(player_color)
	player_duplicate.set_color(duplicate_color)

	player.position = new_pos1
	player_duplicate.position = new_pos2
	
	player_duplicate.visible = true
	
	var tween2 = create_tween().set_parallel(true)
	tween2.tween_property(player, "scale", Vector2(1, 1), 0.4)
	tween2.tween_property(player_duplicate, "scale", Vector2(1, 1), 0.4)
	await tween2.finished

	var level = get_tree().current_scene
	if level != null and level.has_method("on_player_split"):
		level.on_player_split(player, player_duplicate)

func _resolve_player_duplicate() -> Node2D:
	var level = get_tree().current_scene
	if level != null and level.has_method("get_player_duplicate"):
		return level.get_player_duplicate()

	return null
