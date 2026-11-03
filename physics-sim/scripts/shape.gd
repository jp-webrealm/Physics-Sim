extends RigidBody2D

class_name Shape

## world pixels drawn per unit of velocity / acceleration. arrow_editor.gd uses the same factor
const ARROW_SCALE := 0.1
## The below is used so we don't get long ahh arrows
## Higher = snappier, lower = smoother. ~10-15 is a good start.
const ACCEL_SMOOTHING := 12.0

@export var shape_size_x: int = 50
@export var shape_size_y: int = 50
## base hue 0..1. saturation is always full, lightness comes from the mass percentile
@export var hue: float = 0.6

## derived from hue + mass percentile, don't set directly
var shape_color: Color = Color.WHITE
## 0 = lightest shape in the world, 1 = heaviest. set by ShapePalette
var mass_percentile := 0.5

var prev_vel: Vector2
var accel = Vector2(0, 0)
var _has_prev_vel := false

## extra constant acceleration added on top of gravity (the red arrow while paused)
var applied_accel := Vector2.ZERO:
	set(value):
		applied_accel = value
		constant_force = value * mass

var _label: Label
var _last_font_size: int = -1

## energy bookkeeping for collision shake. -1 = unknown
var _ke_prev := -1.0

## pinned in place from the inspector: ignores gravity and can't be pushed,
## but still collides and can hold joints
var frozen := false

func _ready() -> void:
	add_to_group("shapes")
	contact_monitor = true
	max_contacts_reported = 8
	_refresh_color()
	_make_arrows()
	_make_label()
	Sim.request_palette_refresh()

func _exit_tree() -> void:
	if Sim.selected == self:
		Sim.clear_selection()
	Sim.request_palette_refresh()

func set_hue(value: float) -> void:
	hue = value
	_refresh_color()

func set_mass_percentile(value: float) -> void:
	mass_percentile = value
	_refresh_color()

func _refresh_color() -> void:
	shape_color = ShapePalette.make_color(hue, mass_percentile)
	_set_color()

func _set_color() -> void:
	for child in get_children():
		if child is ColorRect:
			child.color = shape_color
			break # Stop looping once found
		elif child is Sprite2D:
			child.modulate = shape_color
			break # Stop looping once found

func _make_arrows() -> void:
	var velocity_arrow = Arrow.new()
	velocity_arrow.color = Color(0.418, 0.602, 1.0, 1.0)
	velocity_arrow.scaling_factor = ARROW_SCALE
	velocity_arrow.value_getter = func() -> Vector2:
		return linear_velocity
	velocity_arrow.handle_visible = _arrow_handles_visible

	var accel_arrow = Arrow.new()
	accel_arrow.color = Color(1.0, 0.339, 0.273, 1.0)
	accel_arrow.scaling_factor = ARROW_SCALE
	# paused: the editable extra acceleration. running: the measured acceleration
	accel_arrow.value_getter = func() -> Vector2:
		return applied_accel if get_tree().paused else accel
	accel_arrow.handle_visible = _arrow_handles_visible

	add_child(velocity_arrow)
	add_child(accel_arrow)
	velocity_arrow.process_mode = Node.PROCESS_MODE_ALWAYS
	accel_arrow.process_mode = Node.PROCESS_MODE_ALWAYS

func _arrow_handles_visible() -> bool:
	return Sim.selected == self and get_tree().paused and not frozen

func set_frozen(value: bool) -> void:
	frozen = value
	freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
	freeze = value
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	reset_tracking()

func set_velocity(vel: Vector2) -> void:
	linear_velocity = vel
	reset_tracking()

func set_initial_state(pos: Vector2, vel: Vector2) -> void:
	global_position = pos
	linear_velocity = vel
	reset_tracking()

## call after changing velocity from outside the physics solver (edits, slingshot launch)
## so it isn't mistaken for energy lost in a collision
func reset_tracking() -> void:
	_ke_prev = -1.0
	_has_prev_vel = false

func contains_point(world_pos: Vector2) -> bool:
	for child in get_children():
		if child is CollisionShape2D and child.shape != null:
			var probe := CircleShape2D.new()
			probe.radius = 0.5
			return child.shape.collide(child.global_transform, probe, Transform2D(0.0, world_pos))
	return false

func _make_label() -> void:
	_label = Label.new()
	_label.top_level = true # ignores the body's rotation and follows only by position
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE # don't eat clicks
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_label)
	# process_frame fires even while the tree is paused, so the label
	# keeps up when you move shapes in the inspector
	get_tree().process_frame.connect(_update_label)
	_update_label()

func _update_label() -> void:
	if not is_instance_valid(_label):
		return
	var box := Vector2(shape_size_x, shape_size_y)
	var text := ("%.1f" % mass).trim_suffix(".0") + "g"
	_label.text = text

	# Fit the text inside the shape: limited by height and by width per character
	var font_size := int(maxf(8.0, minf(minf(box.x, box.y) * 0.5, box.x / (text.length() * 0.6))) * 0.75)
	if font_size != _last_font_size:
		_label.add_theme_font_size_override("font_size", font_size)
		_last_font_size = font_size

	# Dark text on light shapes, light text on dark shapes
	var text_color := Color.BLACK if shape_color.get_luminance() > 0.5 else Color.WHITE
	_label.add_theme_color_override("font_color", text_color)

	_label.size = box
	_label.rotation = 0.0
	_label.global_position = global_position - box / 2.0

## runs just before each physics step, so the velocity here is the result of the last one.
## shapes touching something report how much kinetic energy they just lost (or gained)
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var ke := 0.5 * mass * state.linear_velocity.length_squared()
	if state.inverse_inertia > 0.0:
		ke += 0.5 * state.angular_velocity * state.angular_velocity / state.inverse_inertia
	if _ke_prev >= 0.0 and state.get_contact_count() > 0:
		Sim.energy_delta += _ke_prev - ke
	_ke_prev = ke

func _physics_process(delta: float) -> void:
	if delta <= 0.0:
		return
	if _has_prev_vel:
		var raw_accel := (linear_velocity - prev_vel) / delta
		var t := 1.0 - exp(-ACCEL_SMOOTHING * delta)
		accel = accel.lerp(raw_accel, t)
	prev_vel = linear_velocity
	_has_prev_vel = true
