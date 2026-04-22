extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $Sprite2D/AnimationPlayer

func _ready() -> void:
	pass

func get_color() -> Color:
	return sprite.get_self_modulate()

func set_color(col: Color) -> void:
	sprite.self_modulate = GameColors.canonical(col)
