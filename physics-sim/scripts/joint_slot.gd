## hotbar slot for joints
## click first shape and then 2nd shape
## right click/esc to cancel
extends TextureRect

@export var joint_scene: PackedScene
@export var spawn_parent: Node2D
@export var preview_color := Color(1.0, 0.8, 0.2, 0.7)

var _armed := false
var _hovered := false
var _first: Shape = null
var _preview: Control

func _ready() -> void:
	mouse_entered.connect(func():
		_hovered = true
		_refresh_modulate())
	mouse_exited.connect(func():
		_hovered = false
		_refresh_modulate())

	# top level so preview isn't affected by other visual effects
	_preview = Control.new()
	_preview.top_level = true
	_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview.draw.connect(_draw_preview)
	add_child(_preview)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_set_armed(not _armed)
		accept_event()

## uses _input so shape clicks get picked up here before the inspector selects them
func _input(event: InputEvent) -> void:
	if not _armed:
		return

	if event.is_action_pressed("ui_cancel") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT):
		_set_armed(false)
		get_viewport().set_input_as_handled()
		return

	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var shape := _shape_at(_to_world(event.position))
	if shape == null:
		return
	get_viewport().set_input_as_handled()

	if _first == null or not is_instance_valid(_first):
		_first = shape
	elif shape != _first:
		_make_joint(_first, shape)
		_set_armed(false)

func _process(_delta: float) -> void:
	if _armed:
		_preview.queue_redraw()

func _draw_preview() -> void:
	if not _armed or _first == null or not is_instance_valid(_first):
		return
	var start := get_viewport().get_canvas_transform() * _first.global_position
	var end := get_viewport().get_mouse_position()
	_preview.draw_dashed_line(start, end, preview_color, 3.0, 10.0)
	_preview.draw_circle(start, 6.0, preview_color)

func _make_joint(a: Shape, b: Shape) -> void:
	if joint_scene == null or spawn_parent == null:
		push_error("joint slot needs joint_scene and spawn_parent")
		return
	var joint := joint_scene.instantiate() as HardJoint
	spawn_parent.add_child(joint)
	joint.attach(a, b)

func _set_armed(value: bool) -> void:
	_armed = value
	_first = null
	_refresh_modulate()
	_preview.queue_redraw()

func _refresh_modulate() -> void:
	if _armed:
		self_modulate = Color(1.0, 0.8, 0.2)
	elif _hovered:
		self_modulate = Color(1.5, 1.5, 1.5)
	else:
		self_modulate = Color.WHITE

func _to_world(screen_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * screen_pos

func _shape_at(world_pos: Vector2) -> Shape:
	for node in get_tree().get_nodes_in_group("shapes"):
		if node is Shape and node.contains_point(world_pos):
			return node
	return null
