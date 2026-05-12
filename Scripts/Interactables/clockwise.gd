extends Node2D

func _ready() -> void:
	pass 

func can_move_here(player) -> bool:
	return true
	
func interact(player) -> void:
	match player.get_color():
		GameColors.RED:
			player.set_color(GameColors.YELLOW)
		GameColors.YELLOW:
			player.set_color(GameColors.BLUE)
		GameColors.BLUE:
			player.set_color(GameColors.RED)
		GameColors.PURPLE:
			player.set_color(GameColors.ORANGE)
		GameColors.ORANGE:
			player.set_color(GameColors.GREEN)
		GameColors.GREEN:
			player.set_color(GameColors.PURPLE)
	queue_free()
		
