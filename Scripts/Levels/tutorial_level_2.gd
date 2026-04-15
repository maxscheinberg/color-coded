extends "res://Scripts/Levels/levelbase.gd"


@onready var add_red = $Objects/AddRed
@onready var add_yellow = $Objects/AddYellow
@onready var add_blue = $Objects/AddBlue

@onready var sub_yellow = $Objects/SubYellow

var last_color: Color

func _ready() -> void:
	super._ready()
	last_color = player.get_color()
	_apply_tutorial_rules()


func _process(delta: float) -> void:
	super._process(delta)
	_apply_tutorial_rules()


		
		
func _apply_tutorial_rules() -> void:

	var col: Color = player.get_color()
	

	# default everything off
	add_red.set_grayed(true)
	add_yellow.set_grayed(true)
	add_blue.set_grayed(true)
	sub_yellow.set_grayed(true)

	# white: can claim any primary
	if GameColors.match(col, GameColors.WHITE):
		add_red.set_grayed(false)
		add_yellow.set_grayed(false)
		add_blue.set_grayed(false)

	# red: can subtract red, or mix to secondary with yellow/blue
	elif GameColors.match(col, GameColors.RED):
		add_yellow.set_grayed(false)
		add_blue.set_grayed(false)

	# yellow: can subtract yellow, or mix to secondary with red/blue
	elif GameColors.match(col, GameColors.YELLOW):
		sub_yellow.set_grayed(false)
		add_red.set_grayed(false)
		add_blue.set_grayed(false)

	# blue: can subtract blue, or mix to secondary with red/yellow
	elif GameColors.match(col, GameColors.BLUE):
		add_red.set_grayed(false)
		add_yellow.set_grayed(false)

	# optional: once player is secondary, stop more mixing in tutorial 2
	elif GameColors.match(col, GameColors.ORANGE):
		sub_yellow.set_grayed(false)

	elif GameColors.match(col, GameColors.GREEN):
		sub_yellow.set_grayed(false)
