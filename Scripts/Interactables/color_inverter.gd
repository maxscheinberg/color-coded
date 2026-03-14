extends Node2D

@export var col: Color
@onready var sprite:Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.self_modulate = col
	pass # Replace with function body.

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
