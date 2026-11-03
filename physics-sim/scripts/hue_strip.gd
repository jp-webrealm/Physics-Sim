## rainbow strip for picking a hue. saturation is always full, so there is no way to
## pick white, black or grey. the strip is drawn at mid lightness, the shape's actual
## lightness still comes from its mass
class_name HueStrip
extends Control

signal hue_changed(hue: float)

var hue := 0.6:
	set(value):
		hue = clampf(value, 0.0, 1.0)
		queue_redraw()

var _dragging := false


func _ready() -> void:
	custom_minimum_size = Vector2(0, 28)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if event.pressed:
			_pick(event.position.x)
	elif event is InputEventMouseMotion and _dragging:
		_pick(event.position.x)


func _pick(x: float) -> void:
	hue = x / maxf(size.x, 1.0)
	hue_changed.emit(hue)


func _draw() -> void:
	var steps := 60
	var w := size.x / steps
	for i in steps:
		draw_rect(Rect2(i * w, 0.0, w + 1.0, size.y), ShapePalette.make_color((i + 0.5) / steps, 0.5))
	var x := hue * size.x
	draw_rect(Rect2(x - 3.0, 0.0, 6.0, size.y), Color.WHITE, false, 2.0)
	draw_rect(Rect2(x - 4.0, -1.0, 8.0, size.y + 2.0), Color.BLACK, false, 1.0)
