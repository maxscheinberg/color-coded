extends Node2D

@export var player_real: Node2D
@export var player_duplicate: Node2D

func _ready() -> void:
	pass

func can_move_here(player) -> bool:
	return true
	
func interact(player) -> void:
	var col = player_real.get_color()
	player_real.set_color(player_duplicate.get_color())
	player_duplicate.set_color(col)
