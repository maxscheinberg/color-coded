@tool
extends Control

## Color Wheel UI Node
## Add to any scene as a UI element. Configure entirely from the Inspector.

@export_group("Wheel Setup")
@export var show_primary: bool = true:
	set(v):
		show_primary = v
		queue_redraw()

@export var show_secondary: bool = false:
	set(v):
		show_secondary = v
		queue_redraw()

@export var show_tertiary: bool = false:
	set(v):
		show_tertiary = v
		queue_redraw()

@export var custom_colors: PackedColorArray = []:
	set(v):
		custom_colors = v
		queue_redraw()

@export_group("Size")
@export var wheel_radius: float = 100.0:
	set(v):
		wheel_radius = v
		custom_minimum_size = Vector2(v * 2.0 + 8.0, v * 2.0 + 8.0)
		queue_redraw()

@export var ring_thickness: float = 0.35:
	set(v):
		ring_thickness = v
		queue_redraw()

@export var gap_degrees: float = 3.0:
	set(v):
		gap_degrees = v
		queue_redraw()

# Colors ordered clockwise from top, matching the reference image exactly.
# Primary: Red top, Yellow bottom-right, Blue bottom-left
# Each ring uses 12-position slots so they all align with each other.
# Slot order (12 positions, 30deg each, starting from top):
# 0=Red, 1=Red-Orange, 2=Orange, 3=Yellow-Orange,
# 4=Yellow, 5=Yellow-Green, 6=Green, 7=Blue-Green,
# 8=Blue, 9=Blue-Violet, 10=Violet, 11=Red-Violet

const PRIMARY_COLORS: PackedColorArray = [
	Color(0.910, 0.102, 0.102),  # Red       slot 0
	Color(1.000, 0.843, 0.000),  # Yellow    slot 4
	Color(0.137, 0.420, 0.780),  # Blue      slot 8
]

# Secondary sits between primaries — 3 slices each spanning 2 slots
const SECONDARY_COLORS: PackedColorArray = [
	Color(0.950, 0.490, 0.100),  # Orange    slot 2
	Color(0.120, 0.650, 0.200),  # Green     slot 6
	Color(0.500, 0.200, 0.650),  # Violet    slot 10
]

# Tertiary — 6 slices, the in-between colors
const TERTIARY_COLORS: PackedColorArray = [
	Color(0.920, 0.290, 0.100),  # Red-Orange      slot 1
	Color(0.98, 0.68, 0.1, 1.0),  # Yellow-Orange   slot 3
	Color(0.600, 0.780, 0.100),  # Yellow-Green    slot 5
	Color(0.000, 0.620, 0.500),  # Blue-Green      slot 7
	Color(0.200, 0.200, 0.650),  # Blue-Violet     slot 9
	Color(0.700, 0.050, 0.380),  # Red-Violet      slot 11
]

## The current player color to highlight on the wheel (set automatically via update_with_player)
var _player_color: Color = Color(0, 0, 0, 0)

func _ready() -> void:
	custom_minimum_size = Vector2(wheel_radius * 2.0 + 8.0, wheel_radius * 2.0 + 8.0)
	queue_redraw()

## Called by the player via call_group("uwpc", "update_with_player", self)
func update_with_player(player) -> void:
	_player_color = player.get_color()
	queue_redraw()

func _draw() -> void:
	var center: Vector2 = size * 0.5
	var layers: Array = []

	if show_tertiary:
		layers.append({ "colors": TERTIARY_COLORS, "slots": 6, "offset": 1 })
	if show_secondary:
		layers.append({ "colors": SECONDARY_COLORS, "slots": 3, "offset": 2 })
	if show_primary:
		layers.append({ "colors": PRIMARY_COLORS, "slots": 3, "offset": 0 })
	if not custom_colors.is_empty():
		layers.append({ "colors": custom_colors, "slots": custom_colors.size(), "offset": 0 })

	var layer_count: int = layers.size()
	if layer_count == 0:
		return

	var outer: float = wheel_radius
	var spacing: float = outer / float(layer_count)

	for idx in layer_count:
		var layer_outer: float = outer - float(idx) * spacing
		var layer_inner: float = layer_outer - spacing + (spacing * ring_thickness * 0.5)
		layer_inner = max(layer_inner, 0.0)
		# Innermost layer is always a solid pie — no hole/dot
		if idx == layer_count - 1:
			layer_inner = 0.0
		var data: Dictionary = layers[idx]
		_draw_ring(center, data["colors"], data["slots"], data["offset"], layer_inner, layer_outer)

	# Draw selection outline on top of everything else
	if _player_color.a > 0.0:
		_draw_selection_outline(center, layers)

func _draw_selection_outline(center: Vector2, layers: Array) -> void:
	var outer: float = wheel_radius
	var layer_count: int = layers.size()
	var spacing: float = outer / float(layer_count)

	for idx in layer_count:
		var layer_outer: float = outer - float(idx) * spacing
		var layer_inner: float = layer_outer - spacing + (spacing * ring_thickness * 0.5)
		layer_inner = max(layer_inner, 0.0)
		if idx == layer_count - 1:
			layer_inner = 0.0
		var data: Dictionary = layers[idx]
		var colors: PackedColorArray = data["colors"]
		var total_slots: int = data["slots"]
		var slot_offset: int = data["offset"]
		var slots_per_color: int = 12 / total_slots if total_slots <= 6 else 1
		var slice_deg: float = 30.0 * float(slots_per_color)
		var half_gap: float = gap_degrees * 0.5
		var steps: int = 32

		for i in colors.size():
			if not GameColors.match(colors[i], _player_color):
				continue
			var base_angle: float = -90.0 + float(slot_offset + i * slots_per_color) * 30.0
			var a_start: float = deg_to_rad(base_angle + half_gap)
			var a_end: float   = deg_to_rad(base_angle + slice_deg - half_gap)
			var outline_w: float = 2.5
			var pad: float = 1.5  # small inset so the line sits on the slice edge
			var r_outer: float = layer_outer - pad
			var r_inner: float = layer_inner + pad if layer_inner > 1.0 else 0.0

			# Draw outer arc
			for s in range(steps):
				var a0: float = lerpf(a_start, a_end, float(s) / float(steps))
				var a1: float = lerpf(a_start, a_end, float(s + 1) / float(steps))
				draw_line(
					center + Vector2(cos(a0), sin(a0)) * r_outer,
					center + Vector2(cos(a1), sin(a1)) * r_outer,
					Color.WHITE, outline_w, true)
			# Draw inner arc (or just a dot at center for pie slices)
			if r_inner > 1.0:
				for s in range(steps):
					var a0: float = lerpf(a_start, a_end, float(s) / float(steps))
					var a1: float = lerpf(a_start, a_end, float(s + 1) / float(steps))
					draw_line(
						center + Vector2(cos(a0), sin(a0)) * r_inner,
						center + Vector2(cos(a1), sin(a1)) * r_inner,
						Color.WHITE, outline_w, true)
			# Draw side lines (the two straight radial edges)
			draw_line(
				center + Vector2(cos(a_start), sin(a_start)) * (r_inner if r_inner > 1.0 else 0.0),
				center + Vector2(cos(a_start), sin(a_start)) * r_outer,
				Color.WHITE, outline_w, true)
			draw_line(
				center + Vector2(cos(a_end), sin(a_end)) * (r_inner if r_inner > 1.0 else 0.0),
				center + Vector2(cos(a_end), sin(a_end)) * r_outer,
				Color.WHITE, outline_w, true)

func _draw_ring(center: Vector2, colors: PackedColorArray, total_slots: int, slot_offset: int, inner_r: float, outer_r: float) -> void:
	var count: int = colors.size()
	if count == 0:
		return
	var slot_deg: float = 360.0 / float(total_slots * (12 / total_slots))
	# Compute degrees per slice based on how many slots each color spans
	var slots_per_color: int = 12 / total_slots if total_slots <= 6 else 1
	var slice_deg: float = 30.0 * float(slots_per_color)
	var half_gap: float = gap_degrees * 0.5
	var steps: int = 32

	for i in count:
		var base_angle: float = -90.0 + float(slot_offset + i * slots_per_color) * 30.0
		var a_start: float = deg_to_rad(base_angle + half_gap)
		var a_end: float   = deg_to_rad(base_angle + slice_deg - half_gap)
		var points: PackedVector2Array = PackedVector2Array()

		if inner_r <= 1.0:
			points.append(center)
			for s in range(steps + 1):
				var a: float = lerpf(a_start, a_end, float(s) / float(steps))
				points.append(center + Vector2(cos(a), sin(a)) * outer_r)
		else:
			for s in range(steps + 1):
				var a: float = lerpf(a_start, a_end, float(s) / float(steps))
				points.append(center + Vector2(cos(a), sin(a)) * outer_r)
			for s in range(steps + 1):
				var a: float = lerpf(a_end, a_start, float(s) / float(steps))
				points.append(center + Vector2(cos(a), sin(a)) * inner_r)

		draw_colored_polygon(points, colors[i])
