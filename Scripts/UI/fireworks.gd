extends Node2D

const PIXEL_SIZE := 6
const COLORS := [
	Color(0.91, 0.267, 0.267, 1),   # red
	Color(0.961, 0.784, 0.259, 1),  # yellow
	Color(0.267, 0.533, 0.933, 1),  # blue
	Color(0.18, 0.8, 0.44, 1),      # green
	Color(0.8, 0.58, 0.85, 1),      # purple
	Color(1, 1, 1, 1),               # white
]

var _particles: Array = []
var _launch_timer: float = 0.0
var _screen_size: Vector2

func _ready() -> void:
	_screen_size = get_viewport_rect().size
	_launch_firework()
	_launch_firework()

func _process(delta: float) -> void:
	_launch_timer += delta
	if _launch_timer >= 0.6:
		_launch_timer = 0.0
		_launch_firework()

	for p in _particles:
		p.x += p.vx * delta * 60
		p.y += p.vy * delta * 60
		p.vy += 0.12 * delta * 60
		p.vx *= pow(0.97, delta * 60)
		p.life -= p.decay * delta * 60

	_particles = _particles.filter(func(p): return p.life > 0)
	queue_redraw()

func _draw() -> void:
	for p in _particles:
		var col = p.color
		col.a = p.life
		var px = int(p.x / PIXEL_SIZE) * PIXEL_SIZE
		var py = int(p.y / PIXEL_SIZE) * PIXEL_SIZE
		draw_rect(Rect2(px, py, PIXEL_SIZE, PIXEL_SIZE), col)

func _launch_firework() -> void:
	var tx = 80 + randf() * (_screen_size.x - 160)
	var ty = 60 + randf() * (_screen_size.y * 0.5)
	var color = COLORS[randi() % COLORS.size()]
	var count = 28 + randi() % 16
	for i in count:
		var angle = randf() * TAU
		var speed = 1.5 + randf() * 4.0
		_particles.append({
			"x": tx, "y": ty,
			"vx": cos(angle) * speed,
			"vy": sin(angle) * speed,
			"color": color,
			"life": 1.0,
			"decay": 0.018 + randf() * 0.012
		})
