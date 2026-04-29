extends Node2D

@export var link: Node2D
@export var player_duplicate: Node2D

func can_move_here(player):
	return true

dawfunc teleport(player):
	var teleport_echo: Node2D = player_duplicate
	var show_echo := teleport_echo != null and teleport_echo != player and not teleport_echo.visible

	if show_echo:
		teleport_echo.global_position = player.global_position
		teleport_echo.visible = true

	player.global_position = link.global_position

	if show_echo:
		teleport_echo.anim.play("Blink")
	player.anim.play("Blink")

	await player.anim.animation_finished
	if show_echo:
		await teleport_echo.anim.animation_finished

	if show_echo:
		teleport_echo.visible = false

	return player.global_position
