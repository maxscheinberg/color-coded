extends CharacterBody2D

@export var col: Color
@onready var anim: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var moving = false
var input_dir : Vector2 = Vector2.ZERO
enum { LEFT, RIGHT, UP, DOWN}

func _ready():
	sprite.self_modulate = col
	anim.get_animation("Look Left").loop_mode = Animation.LOOP_NONE
	anim.get_animation("Look Right").loop_mode = Animation.LOOP_NONE
	
#func _physics_process(delta):
	#input_dir = Vector2.ZERO
	#if Input.is_action_just_pressed("ui_down"):
		#input_dir = Vector2(0, 1)
		#move(DOWN)
	#if Input.is_action_just_pressed("ui_up"):
		#input_dir = Vector2(0, -1)
		#move(UP)
	#if Input.is_action_just_pressed("ui_right"):
		#input_dir = Vector2(1, 0)
		#move(RIGHT)
	#if Input.is_action_just_pressed("ui_left"):
		#input_dir = Vector2(-1, 0)
		#move(LEFT)
	#move_and_slide()
	#
#func move(dir):
	#if input_dir:
		#if moving == false:
			#moving = true
			#match dir:
				#LEFT:
					#anim.play("Look Left", -1, 2.0)
				#RIGHT:
					#anim.play("Look Right", -1, 2.0)
			#var tween = create_tween()
			#tween.tween_property(self, "position", position + input_dir*tile_size, 0.35)
			#tween.tween_callback(stop_move)
			#
#func stop_move():
	#moving = false
	#anim.play("Default")
