## Drag the selected shape's arrows to set velocity / extra acceleration. Paused only.
##   - drag an arrow tip (the little circle) to change that arrow
##   - drag from the shape's body to set velocity, Shift + drag to set acceleration
## Add as a Node2D named "ArrowEditor" in the main scene.
extends Node2D

const GRAB_RADIUS := 12.0
## a plain click on the shape shouldn't zero its velocity, so body drags wait for movement
const DRAG_THRESHOLD := 6.0
const MAX_VECTOR := 3000.0

enum Mode { NONE, VELOCITY, ACCEL }

var _mode := Mode.NONE
var _grab_offset := Vector2.ZERO
var _press_pos := Vector2.ZERO
var _moved := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if not get_tree().paused:
		_mode = Mode.NONE
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_try_grab()
		elif _mode != Mode.NONE:
			_mode = Mode.NONE
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and _mode != Mode.NONE:
		_drag()
		get_viewport().set_input_as_handled()


func _try_grab() -> void:
	var shape := Sim.selected
	if not is_instance_valid(shape) or shape.frozen:
		return
	var mouse := get_global_mouse_position()
	var v_tip := shape.global_position + shape.linear_velocity * Shape.ARROW_SCALE
	var a_tip := shape.global_position + shape.applied_accel * Shape.ARROW_SCALE
	var dv := mouse.distance_to(v_tip)
	var da := mouse.distance_to(a_tip)
	var shift := Input.is_key_pressed(KEY_SHIFT)

	if dv <= GRAB_RADIUS or da <= GRAB_RADIUS:
		if dv <= GRAB_RADIUS and da <= GRAB_RADIUS:
			# both tips overlap (zero vectors): shift picks acceleration
			_mode = Mode.ACCEL if shift else Mode.VELOCITY
		else:
			_mode = Mode.VELOCITY if dv < da else Mode.ACCEL
		var tip := v_tip if _mode == Mode.VELOCITY else a_tip
		_grab_offset = tip - mouse
		_moved = true
	elif shape.contains_point(mouse):
		_mode = Mode.ACCEL if shift else Mode.VELOCITY
		_grab_offset = Vector2.ZERO
		_press_pos = mouse
		_moved = false
	else:
		return
	get_viewport().set_input_as_handled()


func _drag() -> void:
	var shape := Sim.selected
	if not is_instance_valid(shape):
		_mode = Mode.NONE
		return
	var mouse := get_global_mouse_position()
	if not _moved:
		if mouse.distance_to(_press_pos) < DRAG_THRESHOLD:
			return
		_moved = true
	var vec := ((mouse + _grab_offset - shape.global_position) / Shape.ARROW_SCALE).limit_length(MAX_VECTOR)
	if _mode == Mode.VELOCITY:
		shape.set_velocity(vec)
	else:
		shape.applied_accel = vec
