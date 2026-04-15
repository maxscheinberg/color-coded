extends Node2D

@export var link: Node2D

func can_move_here(player):
	return true

func teleport(player):
	player.anim.play("Teleport")
	await player.anim.animation_finished
	
	player.global_position = link.global_position

	player.anim.play_backwards("Teleport")
	await player.anim.animation_finished

	return player.global_position
