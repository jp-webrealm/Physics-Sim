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

## Lambda expression that an implementing node sets. 
## Example: a RigidBody would set value_getter to linear_velocity() so that 
## the arrow can get the object's velocity every frame.
## This should return a magnitude and a direction (Vector2D).
var value_getter: Callable

func _process(_delta: float) -> void:
	# Queue a redraw every frame so the arrow updates live
	# Must reset the global rotation so the arrow's direction isn't affected by 
	# the parent rigidbody
	global_rotation = 0.0
	queue_redraw()

func _draw() -> void:
	# Only draw if a valid getter function has been provided
	if value_getter.is_valid():
		# 1. Safely call the passed function to fetch the Vector2
		var vector_value: Vector2 = value_getter.call()
		
		# 2. Scale the vector for the screen layout
		var start_point := Vector2.ZERO
		var end_point := vector_value * scaling_factor
		
		# 3. Draw the line and arrow head
		if end_point.length_squared() > 1.0: # Don't draw if tiny
			draw_line(start_point, end_point, color, 2.0)
			_draw_arrow_head(start_point, end_point)

func _draw_arrow_head(start: Vector2, end: Vector2) -> void:
	var dir := (end - start).normalized()
	var normal := Vector2(-dir.y, dir.x)
	
	var left_hook := end - (dir * head_size) + (normal * head_size * 0.5)
	var right_hook := end - (dir * head_size) - (normal * head_size * 0.5)
	
	draw_line(end, left_hook, color, thickness)
	draw_line(end, right_hook, color, thickness)
