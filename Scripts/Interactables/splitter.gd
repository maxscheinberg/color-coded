extends Node2D

@export var new_pos1: Vector2
@export var new_pos2: Vector2
@export var player_duplicate: Node2D

func is_floor_object() -> bool:
	return true

func interact(player) -> void:
	if player_duplicate == null:
		player_duplicate = _resolve_player_duplicate()

	if player_duplicate == null or player_duplicate.visible:
		return

	player.position = new_pos1
	player_duplicate.position = new_pos2

	if player_duplicate.has_method("set_color") and player.has_method("get_color"):
		player_duplicate.set_color(player.get_color())

	player_duplicate.visible = true

	var level = get_tree().current_scene
	if level != null and level.has_method("on_player_split"):
		level.on_player_split(player, player_duplicate)

func _resolve_player_duplicate() -> Node2D:
	var level = get_tree().current_scene
	if level != null and level.has_method("get_player_duplicate"):
		return level.get_player_duplicate()

	return null
