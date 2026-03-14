extends Node2D

@onready var bodySprite: Sprite2D = $Body
@onready var arrowSprite: Sprite2D = $Arrow

func on_level_start(player):
	update_with_player(player)
			
func update_with_player(player):
	var col = player.get_color()
	set_arrow_color(col)
	match col:
		Color.RED:
			set_body_color(Color.GREEN)
		Color.GREEN:
			set_body_color(Color.RED)
		Color.BLUE:
			set_body_color(Color.ORANGE)
		Color.ORANGE:
			set_body_color(Color.BLUE)
		Color.YELLOW:
			set_body_color(Color.PURPLE)
		Color.PURPLE:
			set_body_color(Color.YELLOW)
	
func can_move_here(player):
	return true

func interact(player):
	match player.get_color():
		Color.RED:
			player.set_color(Color.GREEN)
		Color.GREEN:
			player.set_color(Color.RED)
		Color.BLUE:
			player.set_color(Color.ORANGE)
		Color.ORANGE:
			player.set_color(Color.BLUE)
		Color.YELLOW:
			player.set_color(Color.PURPLE)
		Color.PURPLE:
			player.set_color(Color.YELLOW)
	update_with_player(player)

func set_body_color(col: Color) -> void:
	bodySprite.self_modulate = col
	
func set_arrow_color(col: Color) -> void:
	arrowSprite.self_modulate = col
