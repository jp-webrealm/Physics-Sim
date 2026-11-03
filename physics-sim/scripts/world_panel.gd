## "World" tab: rate of time and gravity
class_name WorldPanel
extends VBoxContainer


func _ready() -> void:
	add_theme_constant_override("separation", 12)

	UIKit.header(self, "Time")
	var time := UIKit.slider(self, "Speed", 0.1, 3.0, 0.05, Sim.time_scale,
		func(v: float) -> void: Sim.time_scale = v, "%.2fx",
		"How fast the simulation runs. Use Stop Simulation to pause completely")
	_preset_row(time, [0.25, 0.5, 1.0, 2.0], "x")

	UIKit.separator(self)

	UIKit.header(self, "Gravity")
	var strength := UIKit.slider(self, "Strength", 0.0, 2000.0, 10.0, Sim.gravity,
		func(v: float) -> void: Sim.gravity = v, "%.0f",
		"Acceleration in px/s². 980 is the default")
	_preset_row(strength, [0.0, 163.0, 980.0], "", ["Zero", "Moon", "Earth"])
	UIKit.slider(self, "Direction", 0.0, 360.0, 5.0, Sim.gravity_angle,
		func(v: float) -> void: Sim.gravity_angle = v, "%.0f°",
		"90 is down, 0 is right, 180 is left, 270 is up")


func _preset_row(target: HSlider, values: Array, suffix: String, names: Array = []) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	add_child(row)
	for i in values.size():
		var value: float = values[i]
		var b := Button.new()
		b.text = names[i] if i < names.size() else _trim(value) + suffix
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(func() -> void: target.value = value)
		row.add_child(b)


## 0.50 -> "0.5", 1.00 -> "1", 980.00 -> "980"
func _trim(value: float) -> String:
	return ("%.2f" % value).rstrip("0").rstrip(".")
