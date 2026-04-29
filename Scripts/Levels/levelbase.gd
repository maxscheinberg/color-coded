extends Node2D

const PLAYER_DUPLICATE_SCENE := preload("res://Scenes/Player/player_duplicate.tscn")

@export var background: TileMapLayer
@export var tilemap_walls: TileMapLayer
@export var objects: Node2D

@export var move_limit: int = -1   # -1 = unlimited, so tutorials stay unaffected

@onready var player = $Player
@onready var camera: Camera2D = $Camera2D

var object_locations: Dictionary = {}
var wall_locations: Array = []
var player_duplicate: Node2D
var controlled_character: Node2D

var moves_used: int = 0
var level_failed: bool = false

enum { LEFT, RIGHT, UP, DOWN }
var player_pos: Vector2i

func _ready() -> void:
	player_duplicate = _ensure_player_duplicate()
	controlled_character = player
	reset_moves()
	object_locations.clear()

	for object in objects.get_children():
		_assign_player_duplicate(object)

		if object.has_method("is_floor_object") and object.is_floor_object():
			if object.has_method("on_level_start"):
				object.on_level_start(controlled_character)
			continue

		var grid_pos = background.local_to_map(object.position)
		object_locations[grid_pos] = object

		if object.has_method("on_level_start"):
			object.on_level_start(controlled_character)

	_refresh_active_character_state()
	_refresh_dynamic_objects()


func _process(_delta: float) -> void:
	if level_failed:
		return

	if Input.is_action_just_pressed("change_character"):
		_change_character()
		return

	if Input.is_action_just_pressed("ui_down"):
		_move_player(DOWN)
	if Input.is_action_just_pressed("ui_up"):
		_move_player(UP)
	if Input.is_action_just_pressed("ui_right"):
		_move_player(RIGHT)
	if Input.is_action_just_pressed("ui_left"):
		_move_player(LEFT)
	if Input.is_action_just_pressed("ui_restart"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("level_swap_1"):
		get_tree().change_scene_to_file("res://Scenes/Levels/brush_level.tscn")
	if Input.is_action_just_pressed("level_swap_2"):
		get_tree().change_scene_to_file("res://Scenes/Levels/brush_tutorial.tscn")

func _move_player(dir: int) -> void:
	if controlled_character == null or _any_character_moving():
		return

	var offset := _dir_offset(dir)
	var current_pos := _get_character_cell(controlled_character)
	var target_cell := current_pos + offset

	if tilemap_walls.get_cell_source_id(target_cell) != -1:
		controlled_character.play_invalid_feedback(
			tilemap_walls.map_to_local(target_cell)
		)
		return

	if _cell_occupied_by_other_character(target_cell, controlled_character):
		return

	var occupying_object = object_locations.get(target_cell)

	# --- Brush mechanic -------------------------------------------------
	# If the player holds a brush and the target is a paintable wall,
	# let the brush paint it instead of blocking movement.
	var held_brush := _find_brush_held_by(controlled_character)
	if occupying_object != null \
			and held_brush != null \
			and occupying_object.has_method("is_paintable") \
			and occupying_object.is_paintable(controlled_character.get_color()):
		use_move()
		held_brush.try_paint(controlled_character, occupying_object)
		# Remove wall from object_locations so the player can now pass
		# (the wall stays in the scene but is now passable via can_move_here)
		_refresh_dynamic_objects()
		return
	# --- End brush mechanic ---------------------------------------------

	if occupying_object != null and not occupying_object.can_move_here(controlled_character):
		controlled_character.play_invalid_feedback(occupying_object.global_position)
		return

	if occupying_object != null and occupying_object.has_method("interact"):
		occupying_object.interact(controlled_character)

	if occupying_object != null and occupying_object.has_method("teleport"):
		controlled_character.moving = true
		use_move()
		await occupying_object.teleport(controlled_character)
		_stop_move(controlled_character, _get_character_cell(controlled_character))
		return

	use_move()

	var tween := create_tween()
	tween.set_parallel(true)
	controlled_character.moving = true

	if dir == LEFT:
		controlled_character.anim.play("Look Left", -1, 2.0)
	elif dir == RIGHT:
		controlled_character.anim.play("Look Right", -1, 2.0)

	tween.tween_property(controlled_character, "position", background.map_to_local(target_cell), 0.15)

	tween.set_parallel(false)
	tween.tween_callback(Callable(self, "_stop_move").bind(controlled_character, target_cell))


func _stop_move(character: Node2D, new_pos: Vector2i) -> void:
	character.anim.play("Default")
	character.moving = false

	var resolved_pos := _process_floor_objects_for(character, new_pos)

	if character == controlled_character:
		player_pos = resolved_pos
	else:
		player_pos = _get_character_cell(controlled_character)

	_refresh_dynamic_objects()

	if _handle_scene_transition():
		return

func _dir_offset(dir: int) -> Vector2i:
	match dir:
		UP:
			return Vector2i(0, -1)
		DOWN:
			return Vector2i(0, 1)
		LEFT:
			return Vector2i(-1, 0)
		RIGHT:
			return Vector2i(1, 0)

	return Vector2i.ZERO


func update_brush_ui(brush_color: Color = Color.TRANSPARENT) -> void:
	if not has_node("CanvasLayer/BrushIndicator"):
		return
	var indicator: TextureRect = $CanvasLayer/BrushIndicator
	if brush_color == Color.TRANSPARENT:
		# no brush held — gray it out
		indicator.self_modulate = Color(0.35, 0.35, 0.35, 1.0)
	else:
		# brush picked up — light it with the player's color
		indicator.self_modulate = brush_color


func update_moves_ui() -> void:
	print("has node: ", has_node("CanvasLayer/MovesContainer/MovesLabel"))
	print("move_limit: ", move_limit)

	if not has_node("CanvasLayer/MovesContainer/MovesLabel"):
		return

	var moves_count = $CanvasLayer/MovesContainer/MovesCount

	if move_limit == -1:
		moves_count.text = ""
	else:
		moves_count.text = str(move_limit - moves_used)


func reset_moves() -> void:
	moves_used = 0
	level_failed = false
	update_moves_ui()
	update_brush_ui()

func use_move() -> void:
	if level_failed:
		return

	if move_limit == -1:
		return

	moves_used += 1
	update_moves_ui()

	if moves_used >= move_limit:
		check_if_out_of_moves()

func check_if_out_of_moves() -> void:
	if player_is_on_goal():
		return

	level_failed = true
	on_out_of_moves()

func on_out_of_moves() -> void:
	print("Out of moves")
	get_tree().reload_current_scene()

func player_is_on_goal() -> bool:
	var scene_name: String = get_tree().current_scene.name

	match scene_name:
		"Tutorial Level 1":
			return _any_character_on_cell(Vector2i(11, 4))
		"Tutorial Level 2":
			return _any_character_on_cell(Vector2i(11, 4))
		"Tutorial Level 3":
			return _any_character_on_cell(Vector2i(1, 8))
		"Level 4":
			return _any_character_on_cell(Vector2i(7, 8))

	return false

func get_player_duplicate() -> Node2D:
	return player_duplicate

func on_player_split(split_player: Node2D, duplicate: Node2D) -> void:
	player_duplicate = duplicate
	player_duplicate.visible = true
	player_duplicate.moving = false
	split_player.moving = false
	split_player.anim.play("Default")
	player_duplicate.anim.play("Default")
	_refresh_active_character_state()
	_refresh_dynamic_objects()

func _change_character() -> void:
	if player_duplicate == null or not player_duplicate.visible or _any_character_moving():
		return
		
	#player.toggle_greyscale()
	#player_duplicate.toggle_greyscale()

	if controlled_character == player:
		controlled_character = player_duplicate
	else:
		controlled_character = player

	_refresh_active_character_state()
	_refresh_dynamic_objects()

func _ensure_player_duplicate() -> Node2D:
	var duplicate = get_node_or_null("PlayerDuplicate")
	if duplicate == null:
		duplicate = PLAYER_DUPLICATE_SCENE.instantiate()
		add_child(duplicate)

	duplicate.position = player.position
	duplicate.visible = false
	duplicate.set_color(player.get_color())
	return duplicate

func _assign_player_duplicate(object: Node) -> void:
	for property in object.get_property_list():
		if property.name == "player_duplicate":
			object.set("player_duplicate", player_duplicate)
			return

func _refresh_active_character_state() -> void:
	if controlled_character == null:
		controlled_character = player

	if controlled_character == player_duplicate and (player_duplicate == null or not player_duplicate.visible):
		controlled_character = player

	player_pos = _get_character_cell(controlled_character)
	get_tree().call_group("uwpc", "update_with_player", controlled_character)

func _refresh_dynamic_objects() -> void:
	for obj in objects.get_children():
		if obj.has_method("update_state"):
			obj.update_state(self)

func _get_character_cell(character: Node2D) -> Vector2i:
	return background.local_to_map(character.position)

func _get_other_character(character: Node2D) -> Node2D:
	if player_duplicate == null or not player_duplicate.visible:
		return null

	if character == player:
		return player_duplicate

	return player


func _cell_occupied_by_other_character(cell: Vector2i, character: Node2D) -> bool:
	var other = _get_other_character(character)
	return other != null and _get_character_cell(other) == cell


func _any_character_moving() -> bool:
	return player.moving or player_duplicate.moving


func _process_floor_objects_for(character: Node2D, start_pos: Vector2i) -> Vector2i:
	var current_pos := start_pos
	var iterations := 0

	while iterations < max(objects.get_child_count(), 1):
		iterations += 1
		var moved_to_new_cell := false

		for obj in objects.get_children():
			if not obj.has_method("is_floor_object") or not obj.is_floor_object():
				continue

			if background.local_to_map(obj.position) != current_pos:
				continue

			if obj.has_method("interact"):
				obj.interact(character)

			var updated_pos := _get_character_cell(character)
			if updated_pos != current_pos:
				current_pos = updated_pos
				moved_to_new_cell = true
				break

		if not moved_to_new_cell:
			break

	return current_pos


func _any_character_on_cell(cell: Vector2i) -> bool:
	if _get_character_cell(player) == cell:
		return true

	if player_duplicate != null and player_duplicate.visible and _get_character_cell(player_duplicate) == cell:
		return true

	return false


func is_character_on_cell(cell: Vector2i) -> bool:
	return _any_character_on_cell(cell)


## Returns the BrushPickup node currently held by `character`, or null.
func _find_brush_held_by(character: Node2D) -> Node2D:
	for obj in objects.get_children():
		if obj.has_method("try_paint") and obj.get("held_by") == character:
			return obj
	return null


func _handle_scene_transition() -> bool:
	var scene_name: String = get_tree().current_scene.name

	if scene_name == "Tutorial Level 1" and _any_character_on_cell(Vector2i(10, 4)):
		_play_level_complete("res://Scenes/Levels/tutorial_level_2.tscn")
		return true

	if scene_name == "Tutorial Level 2" and _any_character_on_cell(Vector2i(10, 4)):
		_play_level_complete("res://Scenes/Levels/tutorial_level_3.tscn")
		return true


	if scene_name == "Tutorial Level 3" and _any_character_on_cell(Vector2i(1, 8)):
		_play_level_complete("res://Scenes/Levels/level_4.tscn")
		return true

	if scene_name == "Level 4" and _any_character_on_cell(Vector2i(7, 8)):
		_play_level_complete("res://Scenes/Levels/level_5.tscn")
		return true

	if scene_name == "Level 5" and _any_character_on_cell(Vector2i(15, 2)):
		_play_level_complete("res://Scenes/Levels/level_6.tscn")
		return true

	if scene_name == "Level 6" and _any_character_on_cell(Vector2i(12, 7)):
		_play_level_complete("res://Scenes/Levels/level_7.tscn")
		return true
		
	if scene_name == "Level 7" and _any_character_on_cell(Vector2i(12, 4)):
		_play_level_complete("res://Scenes/Levels/level_8.tscn")
		return true
		
		

	return false


func _play_level_complete(next_scene: String) -> void:
	level_failed = true

	# Pop all characters
	for character in get_tree().get_nodes_in_group("characters"):
		var tween := create_tween()
		tween.tween_property(character, "scale", Vector2(1.4, 1.4), 0.12)\
			.set_ease(Tween.EASE_OUT)
		tween.tween_property(character, "scale", Vector2(0.0, 0.0), 0.18)\
			.set_ease(Tween.EASE_IN)

	await get_tree().create_timer(0.35).timeout

	# Show level complete screen
	var screen = preload("res://Scenes/UI/level_complete.tscn").instantiate()
	add_child(screen)
	screen.setup(moves_used, move_limit)
	screen.next_pressed.connect(func():
		get_tree().change_scene_to_file(next_scene)
	)
