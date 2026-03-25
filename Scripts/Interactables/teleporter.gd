extends Node2D

@export var link: Node2D
@export var player_duplicate: Node2D

func can_move_here(player):
	return true

func teleport(player):
	player_duplicate.global_position = player.global_position
	player_duplicate.visible = true

	player.global_position = link.global_position

	player_duplicate.anim.play("Blink")
	player.anim.play("Blink")

	await player.anim.animation_finished
	await player_duplicate.anim.animation_finished

	player_duplicate.visible = false

	return player.global_position
