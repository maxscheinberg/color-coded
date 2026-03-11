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
	player.get_child(0).self_modulate = Color.BLUE
