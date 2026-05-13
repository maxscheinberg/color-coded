extends Node

var previous_scene: String = ""

func stop() -> void:
	$AudioStreamPlayer.stop()

func set_volume(db: float) -> void:
	$AudioStreamPlayer.volume_db = db
