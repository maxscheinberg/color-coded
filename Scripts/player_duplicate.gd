extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $Sprite2D/AnimationPlayer

func _ready() -> void:
	anim.get_animation("Blink").loop_mode = Animation.LOOP_NONE

func on_level_start(player):
	self.visible = false
	update_with_player(player)
			
func update_with_player(player):
	sprite.self_modulate = player.get_color()
