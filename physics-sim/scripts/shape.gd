extends RigidBody2D

class_name Shape

@export var shape_size_x: int = 50
@export var shape_size_y: int = 50
@export var shape_weight: int = mass;
@export var shape_color: Color = Color.WHITE

var _label: Label
var _last_font_size: int = -1

func _ready() -> void:
	add_to_group("shapes")
	_set_color()
	_make_arrows()
	_make_label()
	
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
	velocity_arrow.value_getter = func() -> Vector2:
		return linear_velocity
	var accel_arrow = Arrow.new()
	accel_arrow.color = Color(1.0, 0.339, 0.273, 1.0)
	accel_arrow.value_getter = func() -> Vector2:
		return constant_force / shape_weight
	add_child(velocity_arrow)
	add_child(accel_arrow)
	velocity_arrow.process_mode = Node.PROCESS_MODE_ALWAYS
	accel_arrow.process_mode = Node.PROCESS_MODE_ALWAYS
	
func set_initial_state(pos: Vector2, vel: Vector2) -> void:
	global_position = pos
	linear_velocity = vel

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
	var text := str(shape_weight) + str("g");
	_label.text = text

	# Fit the text inside the shape: limited by height and by width per character
	var font_size := int(maxf(8.0, minf(minf(box.x, box.y) * 0.5, box.x / (text.length() * 0.6)))) * 0.75
	if font_size != _last_font_size:
		_label.add_theme_font_size_override("font_size", font_size)
		_last_font_size = font_size

	# Dark text on light shapes, light text on dark shapes
	var text_color := Color.BLACK if shape_color.get_luminance() > 0.5 else Color.WHITE
	_label.add_theme_color_override("font_color", text_color)

	_label.size = box
	_label.rotation = 0.0
	_label.global_position = global_position - box / 2.0

func _physics_process(delta: float) -> void:
	pass
