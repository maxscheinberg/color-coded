extends Node2D

@export var col: Color
@onready var sprite:Sprite2D = $Sprite2D

#dictionary instead of a nested function
const COLOR_MIXES: Dictionary = {
	[Color.RED, Color.BLUE]: Color.PURPLE,
	[Color.BLUE, Color.RED]: Color.PURPLE,
	[Color.RED, Color.YELLOW]: Color.ORANGE,
	[Color.YELLOW, Color.RED]: Color.ORANGE,
	[Color.BLUE, Color.YELLOW]: Color.GREEN,
	[Color.YELLOW, Color.BLUE]: Color.GREEN,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.self_modulate = col
	pass # Replace with function body.

func can_move_here(player):
	return true

func interact(player):
	var result = COLOR_MIXES.get([col, player.get_color()])
	if result:
		player.set_color(result)
