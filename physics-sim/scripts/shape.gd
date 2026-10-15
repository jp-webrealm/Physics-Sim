extends RigidBody2D

class_name Shape

@export var shape_size_x: int = 50
@export var shape_size_y: int = 50
@export var shape_weight: int = 50
@export var shape_color: Color = Color.WHITE
@export var launch_force_multiplier: float = 5.0
@export var max_drag_distance: float = 150.0

var is_dragging := false
var drag_start_center := Vector2.ZERO  # The object's position AT the moment of click
var drag_start_mouse := Vector2.ZERO   # The mouse position AT the moment of click

func _ready() -> void:
	$Polygon2D.color = shape_color
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	print("Shape ready: ", name, " input enabled: ", is_processing_input())

func _input(event: InputEvent) -> void:
	print(global_position.distance_to(get_global_mouse_position()));
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Check distance to current moving body position to see if we grabbed it
			if global_position.distance_to(get_global_mouse_position()) < 60.0:
				start_drag()
		else:
			if is_dragging:
				launch()

func start_drag() -> void:
	is_dragging = true
	# Capture the moving object's exact physics snapshot at this precise frame
	drag_start_center = global_position
	drag_start_mouse = get_global_mouse_position()
	
	# Freeze the physics simulation temporarily so gravity doesn't fight the pull
	freeze = true

func _physics_process(_delta: float) -> void:
	if is_dragging:
		# Calculate how far the mouse has moved from its original click point
		var current_mouse_pos = get_global_mouse_position()
		var mouse_delta = current_mouse_pos - drag_start_mouse
		
		# Clamp the delta to your maximum allowed slingshot stretch distance
		if mouse_delta.length() > max_drag_distance:
			mouse_delta = mouse_delta.normalized() * max_drag_distance
			
		# Move the body relative to where it started its journey
		global_position = drag_start_center + mouse_delta

func launch() -> void:
	is_dragging = false
	freeze = false # Re-enable physics simulation
	
	# Calculate vector from current dragged position BACK to the captured start center
	var launch_vector = drag_start_center - global_position
	var impulse = launch_vector * launch_force_multiplier
	
	# Fire a single instant impulse
	apply_central_impulse(impulse)
