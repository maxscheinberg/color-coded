extends CanvasLayer

@onready var panel: Control = $Panel

func _ready() -> void:
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.8, 0.8)
	get_tree().paused = true
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.2)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_close_pressed() -> void:
	get_tree().paused = false
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.25)
	await tween.finished
	queue_free()
