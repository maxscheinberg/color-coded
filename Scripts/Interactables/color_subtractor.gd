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
	match col:
		Color.RED:
			match player.get_color():
				Color.PURPLE:
					player.set_color(Color.BLUE)
				Color.ORANGE:
					player.set_color(Color.YELLOW)
		Color.BLUE:
			match player.get_color():
				Color.PURPLE:
					player.set_color(Color.RED)
				Color.GREEN:
					player.set_color(Color.YELLOW)
		Color.YELLOW:
			match player.get_color():
				Color.ORANGE:
					player.set_color(Color.RED)
				Color.GREEN:
					player.set_color(Color.BLUE)
