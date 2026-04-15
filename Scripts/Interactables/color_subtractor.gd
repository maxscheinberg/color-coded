extends Node2D

@export var col: Color
@onready var sprite: Sprite2D = $Sprite2D
@onready var invalid_sfx = $InvalidSfx
@onready var valid_sfx = $ValidSfx

var disabled: bool = false

func _ready() -> void:
	col = GameColors.canonical(col)
	sprite.self_modulate = col

func can_move_here(player) -> bool:
	return true

func interact(player):
	if disabled:
		return

	var p: Color = GameColors.canonical(player.get_color())
	var b: Color = GameColors.canonical(col)

	# primary - same = white
	if GameColors.match(p, GameColors.RED) and GameColors.match(b, GameColors.RED):
		play_valid_feedback()
		player.set_color(GameColors.WHITE)
		player.play_valid_feedback()
		return
	elif GameColors.match(p, GameColors.YELLOW) and GameColors.match(b, GameColors.YELLOW):
		play_valid_feedback()
		player.set_color(GameColors.WHITE)
		player.play_valid_feedback()
		return
	elif GameColors.match(p, GameColors.BLUE) and GameColors.match(b, GameColors.BLUE):
		play_valid_feedback()
		player.set_color(GameColors.WHITE)
		player.play_valid_feedback()
		return

	# orange = red + yellow
	elif GameColors.match(p, GameColors.ORANGE) and GameColors.match(b, GameColors.RED):
		play_valid_feedback()
		player.set_color(GameColors.YELLOW)
		player.play_valid_feedback()
		return
	elif GameColors.match(p, GameColors.ORANGE) and GameColors.match(b, GameColors.YELLOW):
		play_valid_feedback()
		player.set_color(GameColors.RED)
		player.play_valid_feedback()
		return

	# green = blue + yellow
	elif GameColors.match(p, GameColors.GREEN) and GameColors.match(b, GameColors.BLUE):
		play_valid_feedback()
		player.set_color(GameColors.YELLOW)
		player.play_valid_feedback()
		return
	elif GameColors.match(p, GameColors.GREEN) and GameColors.match(b, GameColors.YELLOW):
		play_valid_feedback()
		player.set_color(GameColors.BLUE)
		player.play_valid_feedback()
		return

	# purple = red + blue
	elif GameColors.match(p, GameColors.PURPLE) and GameColors.match(b, GameColors.RED):
		play_valid_feedback()
		player.set_color(GameColors.BLUE)
		player.play_valid_feedback()
		return
	elif GameColors.match(p, GameColors.PURPLE) and GameColors.match(b, GameColors.BLUE):
		play_valid_feedback()
		player.set_color(GameColors.RED)
		player.play_valid_feedback()
		return

	# red-orange = red + orange
	elif GameColors.match(p, GameColors.RED_ORANGE) and GameColors.match(b, GameColors.RED):
		play_valid_feedback()
		player.set_color(GameColors.ORANGE)
		player.play_valid_feedback()
		return
	elif GameColors.match(p, GameColors.RED_ORANGE) and GameColors.match(b, GameColors.ORANGE):
		play_valid_feedback()
		player.set_color(GameColors.RED)
		player.play_valid_feedback()
		return

	# yellow-orange = yellow + orange
	elif GameColors.match(p, GameColors.YELLOW_ORANGE) and GameColors.match(b, GameColors.YELLOW):
		play_valid_feedback()
		player.set_color(GameColors.ORANGE)
		player.play_valid_feedback()
		return
	elif GameColors.match(p, GameColors.YELLOW_ORANGE) and GameColors.match(b, GameColors.ORANGE):
		play_valid_feedback()
		player.set_color(GameColors.YELLOW)
		player.play_valid_feedback()
		return

	# yellow-green = yellow + green
	elif GameColors.match(p, GameColors.YELLOW_GREEN) and GameColors.match(b, GameColors.YELLOW):
		play_valid_feedback()
		player.set_color(GameColors.GREEN)
		player.play_valid_feedback()
		return
	elif GameColors.match(p, GameColors.YELLOW_GREEN) and GameColors.match(b, GameColors.GREEN):
		play_valid_feedback()
		player.set_color(GameColors.YELLOW)
		player.play_valid_feedback()
		return

	# blue-green = blue + green
	elif GameColors.match(p, GameColors.BLUE_GREEN) and GameColors.match(b, GameColors.BLUE):
		play_valid_feedback()
		player.set_color(GameColors.GREEN)
		player.play_valid_feedback()
		return
	elif GameColors.match(p, GameColors.BLUE_GREEN) and GameColors.match(b, GameColors.GREEN):
		play_valid_feedback()
		player.set_color(GameColors.BLUE)
		player.play_valid_feedback()
		return

	# blue-violet = blue + purple
	elif GameColors.match(p, GameColors.BLUE_VIOLET) and GameColors.match(b, GameColors.BLUE):
		play_valid_feedback()
		player.set_color(GameColors.PURPLE)
		player.play_valid_feedback()
		return
	elif GameColors.match(p, GameColors.BLUE_VIOLET) and GameColors.match(b, GameColors.PURPLE):
		play_valid_feedback()
		player.set_color(GameColors.BLUE)
		player.play_valid_feedback()
		return

	# red-violet = red + purple
	elif GameColors.match(p, GameColors.RED_VIOLET) and GameColors.match(b, GameColors.RED):
		play_valid_feedback()
		player.set_color(GameColors.PURPLE)
		player.play_valid_feedback()
		return
	elif GameColors.match(p, GameColors.RED_VIOLET) and GameColors.match(b, GameColors.PURPLE):
		play_valid_feedback()
		player.set_color(GameColors.RED)
		player.play_valid_feedback()
		return

	else:
		play_invalid_feedback(player)
		return

func set_grayed(grayed: bool) -> void:
	disabled = grayed
	if grayed:
		sprite.self_modulate = GameColors.GRAYED_OUT
	else:
		sprite.self_modulate = col

func play_invalid_feedback(player) -> void:
	if invalid_sfx:
		invalid_sfx.play()

	var original_pos: Vector2 = position
	var original_scale: Vector2 = sprite.scale
	var original_modulate: Color = sprite.self_modulate

	var tween := create_tween()

	# shake
	tween.tween_property(self, "position", original_pos + Vector2(8, 0), 0.05)
	tween.tween_property(self, "position", original_pos + Vector2(-6, 0), 0.05)
	tween.tween_property(self, "position", original_pos, 0.05)

	# squash
	tween.parallel().tween_property(sprite, "scale", Vector2(1.12, 0.9), 0.05)
	tween.parallel().tween_property(sprite, "self_modulate", Color(1.2, 1.2, 1.2, 1.0), 0.05)

	tween.tween_property(sprite, "scale", original_scale, 0.08)
	tween.parallel().tween_property(sprite, "self_modulate", original_modulate, 0.08)

	if player and player.has_method("play_invalid_feedback"):
		player.play_invalid_feedback(global_position)

func play_valid_feedback() -> void:
	#if valid_sfx:
		#valid_sfx.play()

	var original_scale: Vector2 = sprite.scale
	var original_modulate: Color = sprite.self_modulate

	var tween := create_tween()

	# pop out
	tween.tween_property(sprite, "scale", Vector2(1.15, 1.15), 0.06)
	tween.parallel().tween_property(sprite, "self_modulate", Color(1.25, 1.25, 1.25, 1.0), 0.06)

	# return
	tween.tween_property(sprite, "scale", original_scale, 0.10)
	tween.parallel().tween_property(sprite, "self_modulate", original_modulate, 0.10)
