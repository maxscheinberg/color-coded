extends Node2D

@export var background: TileMapLayer
@export var tilemap_walls: TileMapLayer
@export var objects: Node2D

@export var move_limit: int = -1   # -1 = unlimited, so tutorials stay unaffected

@onready var object_locations: Dictionary[Vector2i, Node]
@onready var wall_locations: Array = []
@onready var player = $Player
@onready var camera: Camera2D = $Camera2D

var moves_used: int = 0
var level_failed: bool = false

enum { LEFT, RIGHT, UP, DOWN }
var player_pos: Vector2i
var move_history: Array = []


func _ready() -> void:
	reset_moves()

	for object in objects.get_children():
		if object.has_method("is_floor_object") and object.is_floor_object():
			if object.has_method("on_level_start"):
				object.on_level_start(player)
			continue

		var grid_pos = background.local_to_map(object.position)
		object_locations[grid_pos] = object

		if object.has_method("on_level_start"):
			object.on_level_start(player)

	player_pos = background.local_to_map(player.position)


func _process(_delta: float) -> void:
	# stop all input if the level already failed
	if level_failed:
		return

	if Input.is_action_just_pressed("ui_down"):
		_move_player(DOWN)
	if Input.is_action_just_pressed("ui_up"):
		_move_player(UP)
	if Input.is_action_just_pressed("ui_right"):
		_move_player(RIGHT)
	if Input.is_action_just_pressed("ui_left"):
		_move_player(LEFT)
	if Input.is_action_just_pressed("ui_undo"):
		_undo_move()
	if Input.is_action_just_pressed("ui_restart"):
		get_tree().reload_current_scene()


func _move_player(dir: int) -> void:
	if player.moving:
		return

	var offset := _dir_offset(dir)
	var target_cell := player_pos + offset

	# Wall check
	if tilemap_walls.get_cell_source_id(target_cell) != -1:
		return

	var occupying_object = object_locations.get(target_cell)

	# Rail direction check
	if occupying_object != null and occupying_object.has_method("get_rail_axis"):
		var rail_axis: String = occupying_object.get_rail_axis()
		var moving_axis := "horizontal" if (dir == LEFT or dir == RIGHT) else "vertical"

		if rail_axis != moving_axis:
			return

	# Collect all rails that are parallel to the player's movement
	var moving_axis := "horizontal" if (dir == LEFT or dir == RIGHT) else "vertical"
	var rails_to_move := {}

	for gp in object_locations.keys():
		var obj = object_locations[gp]

		if not obj.has_method("get_rail_axis"):
			continue
		if obj.get_rail_axis() != moving_axis:
			continue

		if moving_axis == "horizontal" and gp.y == player_pos.y:
			rails_to_move[gp] = obj
		elif moving_axis == "vertical" and gp.x == player_pos.x:
			rails_to_move[gp] = obj

	# Chain through cores
	var extra_rails := {}
	for gp in rails_to_move.keys():
		_collect_core_chains(gp, moving_axis, offset, rails_to_move, extra_rails)

	for gp in extra_rails.keys():
		rails_to_move[gp] = extra_rails[gp]

	# Rail glow feedback
	for gp in object_locations.keys():
		var obj = object_locations[gp]
		if obj.has_method("get_rail_axis"):
			var body = obj.get_node("Body")
			if rails_to_move.has(gp):
				body.color = Color(0.0, 0.75, 1.0)  # will move
			else:
				body.color = Color(0.62, 0.18, 0.31)  # blocked

	# Check blocking object
	if occupying_object != null and not occupying_object.has_method("get_rail_axis"):
		if not occupying_object.can_move_here(player):
			return

	# Check rail collisions
	for gp in rails_to_move.keys():
		var new_gp: Vector2i = gp + offset

		if tilemap_walls.get_cell_source_id(new_gp) != -1:
			return

		if object_locations.has(new_gp) and not rails_to_move.has(new_gp):
			return

	# Snapshot for undo
	var snapshot := {
		"player_pos": player_pos,
		"player_color": player.get_color(),
		"interactions": [],
		"rail_positions": {}
	}

	for gp in rails_to_move.keys():
		snapshot["rail_positions"][rails_to_move[gp]] = gp

	# Handle interact for non-rail objects
	if occupying_object != null and occupying_object.has_method("interact"):
		if occupying_object.has_method("get_color"):
			snapshot["interactions"].append({
				"object": occupying_object,
				"old_color": occupying_object.get_color()
			})

		occupying_object.interact(player)

	# Handle teleport
	if occupying_object != null and occupying_object.has_method("teleport"):
		player.moving = true
		move_history.append(snapshot)

		# Count this as a valid move
		use_move()

		await occupying_object.teleport(player)
		_stop_move(background.local_to_map(player.position))
		return

	move_history.append(snapshot)

	# Count this as a valid move
	use_move()

	# Remove rails from old positions
	for gp in rails_to_move.keys():
		object_locations.erase(gp)

	# Tween everything simultaneously
	var tween := create_tween()
	tween.set_parallel(true)
	player.moving = true

	if dir == LEFT:
		player.anim.play("Look Left", -1, 2.0)
	elif dir == RIGHT:
		player.anim.play("Look Right", -1, 2.0)

	tween.tween_property(player, "position", background.map_to_local(target_cell), 0.15)

	for gp in rails_to_move.keys():
		var new_gp: Vector2i = gp + offset
		object_locations[new_gp] = rails_to_move[gp]
		tween.tween_property(rails_to_move[gp], "position", background.map_to_local(new_gp), 0.15)

	tween.set_parallel(false)
	tween.tween_callback(Callable(self, "_stop_move").bind(target_cell))


func _collect_core_chains(rail_gp: Vector2i, moving_axis: String, offset: Vector2i, existing: Dictionary, extra: Dictionary) -> void:
	var perp_offsets := [Vector2i(0, -1), Vector2i(0, 1)] if moving_axis == "horizontal" else [Vector2i(-1, 0), Vector2i(1, 0)]

	for perp in perp_offsets:
		var neighbor_pos = rail_gp + perp

		if not object_locations.has(neighbor_pos):
			continue

		var neighbor = object_locations[neighbor_pos]

		if not neighbor.has_method("get_core_axis"):
			continue

		var core_axis: String = neighbor.get_core_axis()
		var scan_offsets := [Vector2i(-1, 0), Vector2i(1, 0)] if core_axis == "horizontal" else [Vector2i(0, -1), Vector2i(0, 1)]
		var core_gp := background.local_to_map(neighbor.position)

		for step in scan_offsets:
			var pos = core_gp + step
			while object_locations.has(pos):
				var obj = object_locations[pos]
				if obj.has_method("get_rail_axis") and obj.get_rail_axis() == core_axis:
					if not existing.has(pos):
						extra[pos] = obj
					pos += step
				else:
					break


func _stop_move(new_pos: Vector2i) -> void:
	player_pos = new_pos
	player.anim.play("Default")
	player.moving = false

	for obj in objects.get_children():
		if obj.has_method("is_floor_object") and obj.is_floor_object():
			if background.local_to_map(obj.position) == player_pos:
				if obj.has_method("interact"):
					obj.interact(player)

	var scene_name: String = get_tree().current_scene.name

	if player_pos == Vector2i(11, 4) and scene_name == "Tutorial Level 1":
		get_tree().change_scene_to_file("res://Scenes/Levels/tutorial_level_2.tscn")
		return

	elif player_pos == Vector2i(11, 4) and scene_name == "Tutorial Level 2":
		get_tree().change_scene_to_file("res://Scenes/Levels/tutorial_level_3.tscn")
		return

	elif player_pos == Vector2i(11, 4) and scene_name == "Level 01":
		get_tree().change_scene_to_file("res://Scenes/Levels/level_02.tscn")
		return

	elif player_pos == Vector2i(1, 9) and scene_name == "Level 02":
		get_tree().change_scene_to_file("res://Scenes/Levels/level_03.tscn")
		return

	elif player_pos == Vector2i(1, 8) and scene_name == "Tutorial Level 3":
		get_tree().change_scene_to_file("res://Scenes/Levels/level_4.tscn")
		return
	elif player_pos == Vector2i(7, 8) and scene_name == "Level 4":
		get_tree().change_scene_to_file("res://Scenes/Levels/level_5.tscn")
		return



func _undo_move() -> void:
	if player.moving or move_history.is_empty():
		return

	var snapshot = move_history.pop_back()

	player.set_color(snapshot["player_color"])

	for entry in snapshot["interactions"]:
		if entry["object"] and entry["object"].has_method("set_color"):
			entry["object"].set_color(entry["old_color"])

	# undo move counter too
	if move_limit != -1 and moves_used > 0:
		moves_used -= 1
		update_moves_ui()

	var tween := create_tween()
	tween.set_parallel(true)
	player.moving = true

	for obj in snapshot["rail_positions"].keys():
		var old_pos: Vector2i = snapshot["rail_positions"][obj]
		var current_gp := background.local_to_map(obj.position)
		object_locations.erase(current_gp)
		object_locations[old_pos] = obj
		tween.tween_property(obj, "position", background.map_to_local(old_pos), 0.1)

	tween.tween_property(player, "position", background.map_to_local(snapshot["player_pos"]), 0.1)

	tween.set_parallel(false)
	tween.tween_callback(func():
		player_pos = snapshot["player_pos"]
		player.anim.play("Default")
		player.moving = false
	)


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


func update_moves_ui() -> void:
	# only levels with this label will show move count
	if not has_node("CanvasLayer/MovesLabel"):
		return

	var moves_label = $CanvasLayer/MovesLabel

	if move_limit == -1:
		moves_label.text = ""
	else:
		moves_label.text = "Moves: " + str(move_limit - moves_used)


func reset_moves() -> void:
	moves_used = 0
	level_failed = false
	update_moves_ui()


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

	if scene_name == "Tutorial Level 1" and player_pos == Vector2i(11, 4):
		return true
	elif scene_name == "Tutorial Level 2" and player_pos == Vector2i(11, 4):
		return true
	elif scene_name == "Tutorial Level 3" and player_pos == Vector2i(1, 8):
		return true
	elif scene_name == "Level 4" and player_pos == Vector2i(7, 8):
		return true
		

	return false
