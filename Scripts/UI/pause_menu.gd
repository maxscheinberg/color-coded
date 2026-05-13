extends CanvasLayer

@onready var panel: Control = $Panel

func _ready() -> void:
	visible = false
	get_tree().paused = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if visible:
			_resume()
		else:
			_pause()

func _pause() -> void:
	visible = true
	get_tree().paused = true
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.15)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "modulate:a", 1.0, 0.12)

func _resume() -> void:
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.1)
	await tween.finished
	visible = false
	get_tree().paused = false

func _on_resume_pressed() -> void:
	_resume()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
