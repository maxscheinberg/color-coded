extends Node2D
var target_rotation
var angular_speed = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_rotation = rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation = rotate_toward(rotation, target_rotation*PI/180, angular_speed * delta)
	
func on_level_start(player):
	var col = player.get_color()
	match col:
		Color.RED:
			rotation_degrees = 345
		Color.ORANGE:
			rotation_degrees = 285
		Color.YELLOW:
			rotation_degrees = 225
		Color.GREEN:
			rotation_degrees = 165
		Color.BLUE:
			rotation_degrees = 105
		Color.PURPLE:
			rotation_degrees = 45

func update_with_player(player):
	var col = player.get_color()
	match col:
		Color.RED:
			target_rotation = 345
		Color.ORANGE:
			target_rotation = 285
		Color.YELLOW:
			target_rotation = 225
		Color.GREEN:
			target_rotation = 165
		Color.BLUE:
			target_rotation = 105
		Color.PURPLE:
			target_rotation = 45
