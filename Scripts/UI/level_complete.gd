extends CanvasLayer

signal next_pressed

@onready var panel: Control = $Panel
@onready var moves_label: Label = $Panel/VBox/MovesLabel
@onready var btn_next: Button = $Panel/VBox/BtnNext

func _ready() -> void:
	$ChimeSfx.play()
	panel.scale = Vector2(0.6, 0.6)
	panel.modulate.a = 0.0
	# Animate in
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.18)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "modulate:a", 1.0, 0.14)



func setup(moves_used: int, move_limit: int) -> void:
	if move_limit == -1:
		moves_label.visible = false
	else:
		moves_label.text = "MOVES: " + str(moves_used) + " / " + str(move_limit)

func _on_btn_next_pressed() -> void:
	next_pressed.emit()
