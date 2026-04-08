extends Node2D

func can_move_here(_player) -> bool:
	return true  # player walks onto it

func get_core_axis() -> String:
	return "vertical"
