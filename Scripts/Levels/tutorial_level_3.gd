extends "res://Scripts/Levels/levelbase.gd"

@onready var add_yellow = $Objects/AddYellow
@onready var sub_blue = $Objects/SubBlue
@onready var sub_yellow = $Objects/SubYellow
@onready var add_red = $Objects/AddRed

func _process(delta: float) -> void:
	super._process(delta)
	_apply_tutorial_rules()

func _apply_tutorial_rules() -> void:
	var col: Color = GameColors.canonical(player.get_color())

	# default: everything disabled
	add_yellow.set_grayed(true)
	sub_blue.set_grayed(true)
	sub_yellow.set_grayed(true)
	add_red.set_grayed(true)

	# green → break into primaries
	if GameColors.match(col, GameColors.GREEN):
		sub_blue.set_grayed(false)
		sub_yellow.set_grayed(false)

	# blue → can go back to white or make green with yellow
	elif GameColors.match(col, GameColors.BLUE):
		sub_blue.set_grayed(false)   # blue - blue = white
		add_red.set_grayed(false)    # blue + red = purple

	# yellow → can go back to white or make orange with red
	elif GameColors.match(col, GameColors.YELLOW):
		sub_yellow.set_grayed(false)
		add_red.set_grayed(false)

	# red → can make orange with yellow
	elif GameColors.match(col, GameColors.RED):
		add_yellow.set_grayed(false)

	# purple → can only subtract to red
	elif GameColors.match(col, GameColors.PURPLE):
		sub_blue.set_grayed(false)

	# orange → can only subtract to red
	elif GameColors.match(col, GameColors.ORANGE):
		sub_yellow.set_grayed(false)

	# white → can claim primaries again
	elif GameColors.match(col, GameColors.WHITE):
		add_yellow.set_grayed(false)
		add_red.set_grayed(false)
