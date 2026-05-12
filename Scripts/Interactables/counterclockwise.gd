extends Node2D

func _ready() -> void:
	pass 

func can_move_here(player) -> bool:
	return true

func interact(player) -> void:
	match player.get_color():
		GameColors.RED:
			player.set_color(GameColors.BLUE)
		GameColors.YELLOW:
			player.set_color(GameColors.RED)
		GameColors.BLUE:
			player.set_color(GameColors.YELLOW)
		GameColors.PURPLE:
			player.set_color(GameColors.GREEN)
		GameColors.ORANGE:
			player.set_color(GameColors.PURPLE)
		GameColors.GREEN:
			player.set_color(GameColors.ORANGE)
	queue_free()
