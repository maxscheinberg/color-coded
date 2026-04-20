extends Control

@onready var master_slider: HSlider = $CenterContainer/VBox/MasterSlider
@onready var sfx_slider: HSlider = $CenterContainer/VBox/SFXSlider
@onready var confirm_dialog: ConfirmationDialog = $ConfirmDialog


func _ready() -> void:
	# Restore saved volume values
	master_slider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))

	var sfx_index = AudioServer.get_bus_index("SFX")
	if sfx_index != -1:
		sfx_slider.value = AudioServer.get_bus_volume_linear(sfx_index)


func _on_master_volume_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


func _on_sfx_volume_changed(value: float) -> void:
	var sfx_index = AudioServer.get_bus_index("SFX")
	if sfx_index != -1:
		AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value))


func _on_reset_pressed() -> void:
	confirm_dialog.popup_centered()


func _on_reset_confirmed() -> void:
	# Clear all saved data
	if FileAccess.file_exists("user://save.dat"):
		DirAccess.remove_absolute("user://save.dat")
	# Return to main menu after reset
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
