extends CanvasLayer

@onready var panel: Control = $Panel
@onready var row_space: Control = $Panel/RowSpace
@onready var row_brush: Control = $Panel/RowBrush
@onready var row_paint: Control = $Panel/RowPaint

var _visible_timer: float = 0.0
var SHOW_DURATION := 4.0

func _ready() -> void:
	# Hide context rows by default
	row_space.visible = false
	row_brush.visible = false
	row_paint.visible = false
	_show_hint()

func setup(has_splitter: bool, has_brush: bool, has_paintable: bool) -> void:
	row_space.visible = has_splitter
	row_brush.visible = has_brush
	row_paint.visible = has_paintable
	# Give tutorial level 1 more time so player can read all controls
	if get_tree().current_scene.name == "Tutorial Level 1":
		SHOW_DURATION = 8.0

func _process(delta: float) -> void:
	if _visible_timer > 0.0:
		_visible_timer -= delta
		if _visible_timer <= 0.0:
			_fade_out()

func _show_hint() -> void:
	_visible_timer = SHOW_DURATION
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)

func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.6)
