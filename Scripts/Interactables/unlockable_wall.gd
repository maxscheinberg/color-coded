extends Node2D

@onready var rect: ColorRect = $ColorRect

var unlocked: bool = false

func _ready() -> void:
	_update_visual()

func can_move_here(player):
	return unlocked

func set_unlocked(value: bool) -> void:
	unlocked = value
	_update_visual()

func _update_visual() -> void:
	if rect == null:
		return

	if unlocked:
		rect.color = Color(1, 1, 1, 0.35)
	else:
		rect.color = Color(1, 1, 1, 1)
