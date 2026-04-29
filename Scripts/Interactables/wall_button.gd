extends Node2D

@export var unlockable_wall: Node2D
@onready var sprite: Sprite2D = $Sprite2D

var is_pressed: bool = false

func is_floor_object() -> bool:
	return true

func on_level_start(_player) -> void:
	_refresh_state()

func interact(_player) -> void:
	_refresh_state()

func update_state(level) -> void:
	if level == null or not level.has_method("is_character_on_cell"):
		return

	var button_cell = level.background.local_to_map(position)
	_set_pressed(level.is_character_on_cell(button_cell))

func _refresh_state() -> void:
	var level = get_tree().current_scene
	if level != null:
		update_state(level)

func _set_pressed(pressed: bool) -> void:
	if is_pressed == pressed:
		return

	is_pressed = pressed

	if unlockable_wall != null and unlockable_wall.has_method("set_unlocked"):
		unlockable_wall.set_unlocked(is_pressed)

	if sprite != null:
		if is_pressed:
			sprite.modulate = Color(0.75, 0.75, 0.75, 1.0)
		else:
			sprite.modulate = Color(1, 1, 1, 1)
