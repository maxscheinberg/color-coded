extends Control


func _on_tutorial_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/tutorial_level_1.tscn")


func _on_tutorial_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/tutorial_level_2.tscn")


func _on_tutorial_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/tutorial_level_3.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
