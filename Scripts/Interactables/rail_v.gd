extends Node2D

func can_move_here(_player) -> bool:
	return false

func get_rail_axis() -> String:
	return "vertical"
