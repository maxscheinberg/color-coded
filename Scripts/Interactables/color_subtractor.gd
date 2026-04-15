extends Node2D

@export var col: Color
@onready var sprite: Sprite2D = $Sprite2D

var disabled: bool = false

func _ready() -> void:
	col = GameColors.canonical(col)
	sprite.self_modulate = col

func can_move_here(player) -> bool:
	return true

func interact(player):
	if disabled:
		return
		
	var p: Color = GameColors.canonical(player.get_color())
	var b: Color = GameColors.canonical(col)

	# primary - same = white
	if GameColors.match(p, GameColors.RED) and GameColors.match(b, GameColors.RED):
		player.set_color(GameColors.WHITE)
	elif GameColors.match(p, GameColors.YELLOW) and GameColors.match(b, GameColors.YELLOW):
		player.set_color(GameColors.WHITE)
	elif GameColors.match(p, GameColors.BLUE) and GameColors.match(b, GameColors.BLUE):
		player.set_color(GameColors.WHITE)

	# orange = red + yellow
	elif GameColors.match(p, GameColors.ORANGE) and GameColors.match(b, GameColors.RED):
		player.set_color(GameColors.YELLOW)
	elif GameColors.match(p, GameColors.ORANGE) and GameColors.match(b, GameColors.YELLOW):
		player.set_color(GameColors.RED)

	# green = blue + yellow
	elif GameColors.match(p, GameColors.GREEN) and GameColors.match(b, GameColors.BLUE):
		player.set_color(GameColors.YELLOW)
	elif GameColors.match(p, GameColors.GREEN) and GameColors.match(b, GameColors.YELLOW):
		player.set_color(GameColors.BLUE)

	# purple = red + blue
	elif GameColors.match(p, GameColors.PURPLE) and GameColors.match(b, GameColors.RED):
		player.set_color(GameColors.BLUE)
	elif GameColors.match(p, GameColors.PURPLE) and GameColors.match(b, GameColors.BLUE):
		player.set_color(GameColors.RED)

func set_grayed(grayed: bool) -> void:
	disabled = grayed
	if grayed:
		sprite.self_modulate = Color(0.4, 0.4, 0.4, 1.0)
	else:
		sprite.self_modulate = col
