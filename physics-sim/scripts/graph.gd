## Scrolling line graph of any value (velocity, acceleration, energy...) over time.
## Set `shape` and `value_getter`, then add it to the scene. Samples once per physics tick,
## so it automatically freezes while the sim is paused.
class_name GraphPlot
extends Control

@export var title: String = ""
@export var line_color: Color = Color(0.42, 0.6, 1.0)
## How many seconds of history the graph shows before it starts scrolling
@export var window_seconds: float = 5.0
## Smallest vertical span, so a flat line doesn't get stretched to fill the graph
@export var min_range: float = 1.0

## The shape being graphed
var shape: Shape:
	set(value):
		shape = value
		clear()

## Takes the shape, returns a float. Example:
## func(s: Shape) -> float: return s.linear_velocity.length()
var value_getter: Callable

var _samples := PackedFloat32Array()

func _ready() -> void:
	custom_minimum_size = Vector2(220, 110)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func clear() -> void:
	_samples.clear()
	queue_redraw()

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(shape) or not value_getter.is_valid():
		return
	_samples.append(float(value_getter.call(shape)))
	var max_samples := int(window_seconds * Engine.physics_ticks_per_second)
	if _samples.size() > max_samples:
		_samples = _samples.slice(_samples.size() - max_samples)
	queue_redraw()

func _draw() -> void:
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.6))
	draw_string(font, Vector2(6, 16), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
	if _samples.size() < 2:
		return

	# vertical range always includes zero so the baseline is visible
	var lo := 0.0
	var hi := 0.0
	for v in _samples:
		lo = minf(lo, v)
		hi = maxf(hi, v)
	if hi - lo < min_range:
		hi = lo + min_range

	var plot := Rect2(Vector2(6, 24), size - Vector2(12, 32))
	var max_samples := int(window_seconds * Engine.physics_ticks_per_second)

	# zero line
	var zero_y := plot.end.y - (0.0 - lo) / (hi - lo) * plot.size.y
	draw_line(Vector2(plot.position.x, zero_y), Vector2(plot.end.x, zero_y), Color(1, 1, 1, 0.25), 1.0)

	# the data
	var points := PackedVector2Array()
	for i in _samples.size():
		var x := plot.position.x + plot.size.x * float(i) / float(max_samples - 1)
		var y := plot.end.y - (_samples[i] - lo) / (hi - lo) * plot.size.y
		points.append(Vector2(x, y))
	draw_polyline(points, line_color, 2.0)

	# current value readout
	draw_string(font, Vector2(size.x - 70, 16), "%.1f" % _samples[-1], HORIZONTAL_ALIGNMENT_RIGHT, 64, 12)
