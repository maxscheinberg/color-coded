extends "res://Scripts/Levels/levelbase.gd"

enum Stage { START, WHITE, CHOSEN }
var stage: Stage = Stage.START

@onready var sub_blue   = $Objects/SubBlue
@onready var add_red    = $Objects/AddRed
@onready var add_yellow = $Objects/AddYellow
@onready var add_blue   = $Objects/AddBlue
@onready var sub_red    = $Objects/SubRed
@onready var sub_yellow = $Objects/SubYellow

func _ready() -> void:
	super._ready()
	_apply_stage()


func _process(delta: float) -> void:
	super._process(delta)
	_apply_stage()

	var col: Color = player.get_color()
	match stage:
		Stage.START:
			if col == Color.WHITE:
				stage = Stage.WHITE
				_apply_stage()
		Stage.WHITE:
			if col == Color.RED or col == Color.YELLOW or col == Color.BLUE:
				stage = Stage.CHOSEN
				_apply_stage()
		Stage.CHOSEN:
			if col == Color.WHITE:
				stage = Stage.WHITE
				_apply_stage()
			

func _apply_stage() -> void:
	var chosen: Color = player.get_color()
	var is_white: bool = (chosen == Color.WHITE)

	add_red.set_grayed(not is_white)
	add_yellow.set_grayed(not is_white)
	add_blue.set_grayed(not is_white)

	sub_red.set_grayed(not (chosen.r > 0.5 and chosen.g < 0.5 and chosen.b < 0.5))
	sub_yellow.set_grayed(not (chosen.r > 0.5 and chosen.g > 0.5 and chosen.b < 0.5))
	sub_blue.set_grayed(not (chosen.r < 0.5 and chosen.g < 0.5 and chosen.b > 0.5))
