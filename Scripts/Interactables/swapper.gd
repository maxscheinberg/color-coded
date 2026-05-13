extends Node2D

@export var player_real: Node2D
@export var player_duplicate: Node2D
@onready var sfx: AudioStreamPlayer = $swapSfx

func _ready() -> void:
	pass

func can_move_here(player) -> bool:
	return true
	
func interact(player) -> void:
	sfx.play()  # ← add this line first
	if player == player_real:
		var col = player_duplicate.get_color()
		player_duplicate.set_color(player_real.get_color())
		player_real.set_color(col)
	else: 
		var col = player_real.get_color()
		player_real.set_color(player_duplicate.get_color())
		player_duplicate.set_color(col)
