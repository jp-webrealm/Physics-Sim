## "Selected" tab of the side menu: edit the selected shape and watch its graphs.
## Fields are editable only while paused. While the sim runs they show live values.
class_name SelectedPanel
extends VBoxContainer

var _shape: Shape
var _hint: Label
var _body: VBoxContainer
var _info: Label
var _x: SpinBox
var _y: SpinBox
var _vx: SpinBox
var _vy: SpinBox
var _ax: SpinBox
var _ay: SpinBox
var _freeze: Button
var _hue: HueStrip
var _graphs: GraphPanel


func _ready() -> void:
	add_theme_constant_override("separation", 12)

	_hint = UIKit.caption(self, "Pause the simulation and click a shape to select it. Its settings and graphs show up here.")

	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 8)
	add_child(_body)

	_info = Label.new()
	_body.add_child(_info)

	UIKit.header(_body, "Position")
	_x = UIKit.spin(_body, "X ", " px", 48.0, 1872.0, 0.25)
	_y = UIKit.spin(_body, "Y ", " px", 48.0, 1040.0, 0.25)

	UIKit.header(_body, "Velocity")
	_vx = UIKit.spin(_body, "X ", " px/s", -3000.0, 3000.0, 5.0, true)
	_vy = UIKit.spin(_body, "Y ", " px/s", -3000.0, 3000.0, 5.0, true)

	UIKit.header(_body, "Extra acceleration")
	_ax = UIKit.spin(_body, "X ", " px/s²", -3000.0, 3000.0, 5.0, true)
	_ay = UIKit.spin(_body, "Y ", " px/s²", -3000.0, 3000.0, 5.0, true)
	UIKit.caption(_body, "A constant push added on top of gravity. You can also drag the arrows on the shape while paused (Shift-drag from the shape body for acceleration).")

	_freeze = Button.new()
	_freeze.tooltip_text = "Pin this shape in place. It ignores gravity and can't be pushed, but still collides and holds joints"
	_body.add_child(_freeze)

	UIKit.header(_body, "Color")
	_hue = HueStrip.new()
	_body.add_child(_hue)

	UIKit.header(_body, "Graphs")
	_graphs = GraphPanel.new()
	_graphs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_child(_graphs)

	for spin in [_x, _y, _vx, _vy, _ax, _ay]:
		spin.value_changed.connect(_on_edited)
	_freeze.pressed.connect(_on_freeze_pressed)
	_hue.hue_changed.connect(_on_hue_changed)
	Sim.selection_changed.connect(_on_selection_changed)
	_on_selection_changed(Sim.selected)


func _on_selection_changed(shape: Shape) -> void:
	_shape = shape
	_hint.visible = shape == null
	_body.visible = shape != null
	_graphs.set_shape(shape)
	if shape != null:
		_hue.hue = shape.hue


func _process(_delta: float) -> void:
	if not is_instance_valid(_shape):
		return
	var paused := get_tree().paused
	var free_to_edit := paused and not _shape.frozen
	_x.editable = paused
	_y.editable = paused
	for spin in [_vx, _vy, _ax, _ay]:
		spin.editable = free_to_edit
	_freeze.disabled = not paused
	_freeze.text = "Unfreeze Object" if _shape.frozen else "Freeze Object"

	_set_spin(_x, _shape.global_position.x)
	_set_spin(_y, _shape.global_position.y)
	_set_spin(_vx, _shape.linear_velocity.x)
	_set_spin(_vy, _shape.linear_velocity.y)
	_set_spin(_ax, _shape.applied_accel.x)
	_set_spin(_ay, _shape.applied_accel.y)
	_info.text = "Mass %s g   (mass percentile %d)" % [
		("%.1f" % _shape.mass).trim_suffix(".0"), roundi(_shape.mass_percentile * 100.0)]


## don't overwrite a field while the user is typing in it
func _set_spin(spin: SpinBox, value: float) -> void:
	if not spin.get_line_edit().has_focus():
		spin.set_value_no_signal(value)


func _on_edited(_value: float) -> void:
	if not is_instance_valid(_shape):
		return
	_shape.set_initial_state(Vector2(_x.value, _y.value), Vector2(_vx.value, _vy.value))
	_shape.applied_accel = Vector2(_ax.value, _ay.value)


func _on_freeze_pressed() -> void:
	if not is_instance_valid(_shape):
		return
	_shape.set_frozen(not _shape.frozen)


func _on_hue_changed(h: float) -> void:
	if is_instance_valid(_shape):
		_shape.set_hue(h)
