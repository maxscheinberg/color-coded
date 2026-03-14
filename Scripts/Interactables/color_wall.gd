extends Node2D

@export var col: Color
@onready var rect: ColorRect = $ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rect.self_modulate = col
	
func _process(delta: float) -> void:
	pass

func can_move_here(player) -> bool:
	return player.get_color() == col
