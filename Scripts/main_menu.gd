extends Control
 
 
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/tutorial_level_1.tscn")
 
 
func _on_level_select_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/level_select.tscn")
	pass
 
 
func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/settings.tscn")
 
 
func _on_quit_pressed() -> void:
	get_tree().quit()
