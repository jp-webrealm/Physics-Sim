## draws pixel rulers on the top and left walls so positions in the inspector
## can be matched to the screen. drawn in world space so it lines up with shapes
extends Node2D

## thickness of the ceiling and left wall the rulers sit on
@export var top_band: float = 51.0
@export var left_band: float = 52.0
## where the labels stop (start of the right wall / floor)
@export var max_x: float = 1872.0
@export var max_y: float = 1036.0
@export var major_step: int = 100
@export var minor_step: int = 50
@export var tick_color := Color(0.55, 0.55, 0.55)
@export var label_color := Color(0.7, 0.7, 0.7)
@export var font_size: int = 12


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var ascent := font.get_ascent(font_size)

	for x in range(minor_step, int(max_x), minor_step):
		var major := x % major_step == 0
		var length := 12.0 if major else 6.0
		draw_line(Vector2(x, top_band - length), Vector2(x, top_band), tick_color, 1.0)
		if major:
			var label := str(x)
			var width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			draw_string(font, Vector2(x - width / 2.0, top_band - 16.0), label,
				HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, label_color)

	for y in range(minor_step, int(max_y), minor_step):
		var major := y % major_step == 0
		var length := 12.0 if major else 6.0
		draw_line(Vector2(left_band - length, y), Vector2(left_band, y), tick_color, 1.0)
		if major:
			var label := str(y)
			var width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			draw_string(font, Vector2(left_band - 16.0 - width, y + ascent / 2.0 - 1.0), label,
				HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, label_color)
