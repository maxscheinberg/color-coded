extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/level_01.tscn")

func _on_level_select_pressed() -> void:
	# Hook this up later when you have a level select screen
	pass

func _on_settings_pressed() -> void:
	# Hook this up later when you have a settings screen
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()
