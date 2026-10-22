extends RigidBody2D

class_name Shape

@export var shape_size_x: int = 50
@export var shape_size_y: int = 50
@export var shape_weight: int = 50
@export var shape_color: Color = Color.WHITE

func _ready() -> void: 
	_set_color()
	_make_arrows()
	
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

func _physics_process(delta: float) -> void:
	pass
