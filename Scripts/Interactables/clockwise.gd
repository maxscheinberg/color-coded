extends Node2D
@onready var sfx: AudioStreamPlayer = $rotateSfx


func _ready() -> void:
	pass 
	
func is_floor_object() -> bool:
	return true
	
func interact(player) -> void:
	sfx.play()  # ← add this line first
	
	match player.get_color():
		GameColors.RED:
			player.set_color(GameColors.YELLOW)
		GameColors.YELLOW:
			player.set_color(GameColors.BLUE)
		GameColors.BLUE:
			player.set_color(GameColors.RED)
		GameColors.PURPLE:
			player.set_color(GameColors.ORANGE)
		GameColors.ORANGE:
			player.set_color(GameColors.GREEN)
		GameColors.GREEN:
			player.set_color(GameColors.PURPLE)
	await get_tree().create_timer(0.15).timeout
	$Sprite2D.visible = false
	await sfx.finished
	queue_free()
		
