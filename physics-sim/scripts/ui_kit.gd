## small helpers so the side menu tabs can be built in code
class_name UIKit

const MUTED := Color(0.6, 0.6, 0.6)


static func header(parent: Control, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 15)
	parent.add_child(label)
	return label


static func caption(parent: Control, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", MUTED)
	parent.add_child(label)
	return label


static func separator(parent: Control) -> HSeparator:
	var sep := HSeparator.new()
	parent.add_child(sep)
	return sep


## label + live value + slider. on_change gets the new value
static func slider(parent: Control, title: String, lo: float, hi: float, step: float,
		value: float, on_change: Callable, fmt := "%.2f", tooltip := "") -> HSlider:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	parent.add_child(box)

	var row := HBoxContainer.new()
	box.add_child(row)
	var name_label := Label.new()
	name_label.text = title
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	var value_label := Label.new()
	value_label.custom_minimum_size = Vector2(64, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value_label)

	var s := HSlider.new()
	s.min_value = lo
	s.max_value = hi
	s.step = step
	s.value = value
	s.custom_minimum_size = Vector2(0, 22)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.tooltip_text = tooltip
	box.add_child(s)

	value_label.text = fmt % s.value
	s.value_changed.connect(func(v: float) -> void:
		value_label.text = fmt % v
		on_change.call(v))
	return s


static func check(parent: Control, text: String, pressed: bool, on_toggle: Callable) -> CheckButton:
	var c := CheckButton.new()
	c.text = text
	c.button_pressed = pressed
	parent.add_child(c)
	c.toggled.connect(on_toggle)
	return c


static func spin(parent: Control, prefix: String, suffix: String, lo: float, hi: float,
		step: float, free_range := false) -> SpinBox:
	var s := SpinBox.new()
	s.custom_minimum_size = Vector2(0, 32)
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.min_value = lo
	s.max_value = hi
	s.step = step
	s.allow_greater = free_range
	s.allow_lesser = free_range
	s.prefix = prefix
	s.suffix = suffix
	parent.add_child(s)
	SpinBoxHelper.select_all_on_focus(s)
	return s
