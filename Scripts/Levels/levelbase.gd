# LevelBase.gd
extends Node2D

@export var background: TileMapLayer
@export var tilemap_walls: TileMapLayer
@export var objects: Node2D
@onready var object_locations: Dictionary[Vector2i, Node]
@onready var wall_locations: Array = []
@onready var player = $Player
enum { LEFT, RIGHT, UP, DOWN}

var player_pos: Vector2i

func _ready() -> void:
	#Find all the objects in the level and place them in the object locations
	#array based on their position. Object locations array is used to check if
	#the player can move to a tile.
	for object in objects.get_children():
		var grid_pos = background.local_to_map(object.position)
		object_locations[grid_pos] = object
		if object.has_method("on_level_start"):
			object.on_level_start(player)
	player_pos = background.local_to_map(player.position)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		_move_player(DOWN)
	if Input.is_action_just_pressed("ui_up"):
		_move_player(UP)
	if Input.is_action_just_pressed("ui_right"):
		_move_player(RIGHT)
	if Input.is_action_just_pressed("ui_left"):
		_move_player(LEFT)
	
func _move_player(dir: int) -> void:
	if player.moving:
		return

	var offset := Vector2i.ZERO
	match dir:
		DOWN:
			offset = Vector2i(0, 1)
		UP:
			offset = Vector2i(0, -1)
		RIGHT:
			offset = Vector2i(1, 0)
		LEFT:
			offset = Vector2i(-1, 0)

	var target_cell: Vector2i = player_pos + offset
	var occupying_object = object_locations.get(target_cell)
	
	#All interactables must have a can_move_here method
	if occupying_object == null or occupying_object.can_move_here(player):
		if occupying_object:
			if occupying_object.has_method("teleport"):
				player.moving = true
				await occupying_object.teleport(player)
				var temp = background.local_to_map(player.position)
				_stop_move(temp)
				return
			if occupying_object.has_method("interact"):
				occupying_object.interact(player)
		player.moving = true
		if dir == LEFT:
			player.anim.play("Look Left", -1, 2.0)
		if dir == RIGHT:
			player.anim.play("Look Right", -1, 2.0)
		var new_pos: Vector2i = target_cell
		var tween := create_tween()
		tween.tween_property(player, "position", background.map_to_local(new_pos), 0.15)
		tween.tween_callback(Callable(self, "_stop_move").bind(new_pos))


func _stop_move(new_pos: Vector2i) -> void:
	player_pos = new_pos
	player.anim.play("Default")
	player.moving = false
	#Just mock code to get prototype working. To be replaced
	if player_pos == Vector2i(11, 4) and get_tree().current_scene.name == "Level 01":
		get_tree().change_scene_to_file("res://Scenes/Levels/level_02.tscn")
	if player_pos == Vector2i(1, 9) and get_tree().current_scene.name == "Level 02":
		get_tree().change_scene_to_file("res://Scenes/Levels/level_03.tscn")
	#if player_pos == Vector2i(12, 12) and get_tree().current_scene.name == "Level 03":
	#	get_tree().change_scene_to_file("res://Scenes/Levels/level_04.tscn")
