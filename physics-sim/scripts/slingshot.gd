## Click-and-drag slingshot. While the sim is running, click a shape, pull back,
## and release to launch it opposite the pull (like Angry Birds).
## Add as a Node2D named "Slingshot" at the origin of your main scene.
extends Node2D

## Impulse per pixel of pull (like a spring constant: bigger = stronger launch).
## Launch speed = stiffness * pull / mass, so heavier shapes launch slower.
@export var stiffness: float = 10.0
## Max pull distance in pixels
@export var max_pull: float = 150.0
## Pulls shorter than this are treated as a cancel
@export var dead_zone: float = 8.0
## Freeze the shape in place while aiming so gravity doesn't drag it away
@export var hold_while_aiming: bool = true
## Your full-screen drop area, so clicks on it aren't mistaken for clicks on UI
@export var drop_area: Control

var _grabbed: Shape = null
var _pull := Vector2.ZERO # shape -> mouse, clamped to max_pull

func _ready() -> void:
	# keep running while paused so we can cancel a drag if the sim gets paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 100

# _input (not _unhandled_input) because a full-screen Control with mouse_filter = Stop
# swallows clicks before they ever reach _unhandled_input
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_try_grab()
		elif _grabbed != null:
			_release()

func _process(_delta: float) -> void:
	if _grabbed == null:
		return
	if not is_instance_valid(_grabbed) or get_tree().paused:
		_cancel()
		return
	_pull = (get_global_mouse_position() - _grabbed.global_position).limit_length(max_pull)
	queue_redraw()

func _try_grab() -> void:
	if get_tree().paused or _is_over_ui():
		return
	var mouse := get_global_mouse_position()
	for node in get_tree().get_nodes_in_group("shapes"):
		if node is Shape and node.contains_point(mouse):
			_grabbed = node
			_pull = Vector2.ZERO
			if hold_while_aiming:
				_grabbed.linear_velocity = Vector2.ZERO
				_grabbed.angular_velocity = 0.0
				_grabbed.freeze = true
			return

func _release() -> void:
	var shape := _grabbed
	var launch := -_pull * stiffness # impulse (mass * velocity), opposite the pull
	var pulled_enough := _pull.length() >= dead_zone
	_cancel()
	if not is_instance_valid(shape):
		return
	shape.freeze = false
	if pulled_enough:
		# same result as apply_central_impulse, but safe to call right after unfreezing
		shape.linear_velocity += launch / shape.mass

func _cancel() -> void:
	if is_instance_valid(_grabbed) and hold_while_aiming:
		_grabbed.freeze = false
	_grabbed = null
	_pull = Vector2.ZERO
	queue_redraw()

func _is_over_ui() -> bool:
	var hovered := get_viewport().gui_get_hovered_control()
	return hovered != null and hovered != drop_area

func _draw() -> void:
	if _grabbed == null or not is_instance_valid(_grabbed):
		return
	var origin := to_local(_grabbed.global_position)
	var pull_end := origin + _pull

	# the "rubber band" you're stretching
	draw_line(origin, pull_end, Color(1, 1, 1, 0.5), 2.0)
	draw_circle(pull_end, 5.0, Color(1, 1, 1, 0.8))

	# where it will fly
	if _pull.length() >= dead_zone:
		var launch_end := origin - _pull
		var dir := (launch_end - origin).normalized()
		var normal := Vector2(-dir.y, dir.x)
		var color := Color(1.0, 0.85, 0.2)
		draw_line(origin, launch_end, color, 2.0)
		draw_line(launch_end, launch_end - dir * 10.0 + normal * 5.0, color, 2.0)
		draw_line(launch_end, launch_end - dir * 10.0 - normal * 5.0, color, 2.0)
