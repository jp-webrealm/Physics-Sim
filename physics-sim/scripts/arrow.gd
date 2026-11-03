## Should be attached to an object whose parent is a RigidBody2D
class_name Arrow
extends Node2D

## Color of the arrow
@export var color: Color = Color.WHITE
## Magnitude to pixels ratio
@export var scaling_factor: float = 0.1
## Thickness of the arrow
@export var thickness: float = 2
## Size of the arrowhead
@export var head_size: float = 10
## Radius of the draggable circle at the tip
@export var handle_radius: float = 6.0

## Lambda expression that an implementing node sets.
## Example: a RigidBody would set value_getter to linear_velocity() so that
## the arrow can get the object's velocity every frame.
## This should return a magnitude and a direction (Vector2D).
var value_getter: Callable
## Optional: returns true when the draggable tip circle should be shown
var handle_visible: Callable

func _process(_delta: float) -> void:
	# Queue a redraw every frame so the arrow updates live
	# Must reset the global rotation so the arrow's direction isn't affected by
	# the parent rigidbody
	global_rotation = 0.0
	queue_redraw()

func _draw() -> void:
	# Only draw if a valid getter function has been provided
	if not value_getter.is_valid():
		return
	var vector_value: Vector2 = value_getter.call()
	var start_point := Vector2.ZERO
	var end_point := vector_value * scaling_factor

	if end_point.length_squared() > 1.0: # Don't draw if tiny
		draw_line(start_point, end_point, color, 2.0)
		_draw_arrow_head(start_point, end_point)

	if handle_visible.is_valid() and handle_visible.call():
		draw_circle(end_point, handle_radius, Color(color, 0.35))
		draw_arc(end_point, handle_radius, 0.0, TAU, 20, color, 2.0)

func _draw_arrow_head(start: Vector2, end: Vector2) -> void:
	var dir := (end - start).normalized()
	var normal := Vector2(-dir.y, dir.x)

	var left_hook := end - (dir * head_size) + (normal * head_size * 0.5)
	var right_hook := end - (dir * head_size) - (normal * head_size * 0.5)

	draw_line(end, left_hook, color, thickness)
	draw_line(end, right_hook, color, thickness)
