extends RefCounted
class_name GameColors

const RED: Color = Color(0.91, 0.102, 0.102, 1.0)
const YELLOW: Color = Color(1.0, 0.843, 0.0, 1.0)
const BLUE: Color = Color(0.137, 0.42, 0.78, 1.0)

const ORANGE: Color = Color(0.95, 0.49, 0.1, 1.0)
const GREEN: Color = Color(0.12, 0.65, 0.2, 1.0)
const PURPLE: Color = Color(0.5, 0.2, 0.65, 1.0)

const RED_ORANGE: Color = Color(1.0, 0.25, 0.0, 1.0)
const YELLOW_ORANGE: Color = Color(1.0, 0.75, 0.0, 1.0)
const YELLOW_GREEN: Color = Color(0.5, 1.0, 0.0, 1.0)
const BLUE_GREEN: Color = Color(0.0, 0.5, 0.5, 1.0)
const BLUE_VIOLET: Color = Color(0.0, 0.0, 0.5, 1.0)
const RED_VIOLET: Color = Color(0.75, 0.0, 0.25, 1.0)

const WHITE: Color = Color(1.0, 1.0, 1.0, 1.0)
const GRAYED_OUT: Color = Color(0.4, 0.4, 0.4, 1.0)


#color_match instead of using ==
static func match(a: Color, b: Color, tolerance: float = 0.01) -> bool:
	return abs(a.r - b.r) <= tolerance \
		and abs(a.g - b.g) <= tolerance \
		and abs(a.b - b.b) <= tolerance \
		and abs(a.a - b.a) <= tolerance

static func canonical(color: Color) -> Color:
	if match(color, WHITE):
		return WHITE
	elif match(color, RED):
		return RED
	elif match(color, YELLOW):
		return YELLOW
	elif match(color, BLUE):
		return BLUE
	elif match(color, ORANGE):
		return ORANGE
	elif match(color, GREEN):
		return GREEN
	elif match(color, PURPLE):
		return PURPLE
	elif match(color, RED_ORANGE):
		return RED_ORANGE
	elif match(color, YELLOW_ORANGE):
		return YELLOW_ORANGE
	elif match(color, YELLOW_GREEN):
		return YELLOW_GREEN
	elif match(color, BLUE_GREEN):
		return BLUE_GREEN
	elif match(color, BLUE_VIOLET):
		return BLUE_VIOLET
	elif match(color, RED_VIOLET):
		return RED_VIOLET
	return color
