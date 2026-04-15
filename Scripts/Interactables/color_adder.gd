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

	# white claims a primary
	if GameColors.match(p, GameColors.WHITE):
		player.set_color(b)
		return

	# primary + primary = secondary
	if GameColors.match(p, GameColors.RED) and GameColors.match(b, GameColors.BLUE):
		player.set_color(GameColors.PURPLE)
	elif GameColors.match(p, GameColors.BLUE) and GameColors.match(b, GameColors.RED):
		player.set_color(GameColors.PURPLE)

	elif GameColors.match(p, GameColors.RED) and GameColors.match(b, GameColors.YELLOW):
		player.set_color(GameColors.ORANGE)
	elif GameColors.match(p, GameColors.YELLOW) and GameColors.match(b, GameColors.RED):
		player.set_color(GameColors.ORANGE)

	elif GameColors.match(p, GameColors.BLUE) and GameColors.match(b, GameColors.YELLOW):
		player.set_color(GameColors.GREEN)
	elif GameColors.match(p, GameColors.YELLOW) and GameColors.match(b, GameColors.BLUE):
		player.set_color(GameColors.GREEN)



		
func set_grayed(grayed: bool) -> void:
	disabled = grayed
	if grayed:
		sprite.self_modulate = Color(0.4, 0.4, 0.4, 1.0)
	else:
		sprite.self_modulate = col
