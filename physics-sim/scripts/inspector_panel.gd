extends PanelContainer

var selected: Shape = null

@onready var x_spin: SpinBox = %XSpin
@onready var y_spin: SpinBox = %YSpin
@onready var vx_spin: SpinBox = %VxSpin
@onready var vy_spin: SpinBox = %VySpin
@onready var freeze_button: Button = %FreezeButton

func _ready() -> void:
	x_spin.value_changed.connect(_on_value_changed)
	y_spin.value_changed.connect(_on_value_changed)
	vx_spin.value_changed.connect(_on_value_changed)
	vy_spin.value_changed.connect(_on_value_changed)
	freeze_button.pressed.connect(_on_freeze_pressed)
	for spin in [x_spin, y_spin, vx_spin, vy_spin]:
		SpinBoxHelper.select_all_on_focus(spin)

func _process(_delta: float) -> void:
	# Only editable while paused; hide once the sim starts
	visible = selected != null and is_instance_valid(selected) and get_tree().paused

func _unhandled_input(event: InputEvent) -> void:
	if not get_tree().paused:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world_pos: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * event.position
		for node in get_tree().get_nodes_in_group("shapes"):
			if node is Shape and node.contains_point(world_pos):
				_select(node)
				return
		selected = null
		
signal shape_selected(shape: Shape)

func _select(shape: Shape) -> void:
	selected = shape
	shape_selected.emit(shape)
	# set_value_no_signal avoids triggering _on_value_changed while populating
	x_spin.set_value_no_signal(shape.global_position.x)
	y_spin.set_value_no_signal(shape.global_position.y)
	vx_spin.set_value_no_signal(shape.linear_velocity.x)
	vy_spin.set_value_no_signal(shape.linear_velocity.y)
	_refresh_freeze_button()

func clear_selection() -> void:
	selected = null
	shape_selected.emit(null)

func _on_freeze_pressed() -> void:
	if selected == null or not is_instance_valid(selected):
		return
	selected.set_frozen(not selected.frozen)
	vx_spin.set_value_no_signal(0.0)
	vy_spin.set_value_no_signal(0.0)
	_refresh_freeze_button()

func _refresh_freeze_button() -> void:
	freeze_button.text = "Unfreeze Object" if selected.frozen else "Freeze Object"

func _on_value_changed(_value: float) -> void:
	if selected == null or not is_instance_valid(selected):
		return
	selected.set_initial_state(
		Vector2(x_spin.value, y_spin.value),
		Vector2(vx_spin.value, vy_spin.value)
	)
