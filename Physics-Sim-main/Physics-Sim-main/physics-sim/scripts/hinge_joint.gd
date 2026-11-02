## pins two shapes together at a single point so they can only rotate around it
extends ShapeJoint

## pivot point stored relative to body_a so the drawing follows it as it moves and spins
var _pivot_on_a := Vector2.ZERO


func _build(pivot: Vector2) -> void:
	var pin := $Pin as PinJoint2D
	pin.global_position = pivot
	pin.softness = 0.0
	pin.disable_collision = true
	pin.node_a = body_a.get_path()
	pin.node_b = body_b.get_path()
	_pivot_on_a = body_a.to_local(pivot)


func _draw_joint(a: Vector2, b: Vector2) -> void:
	var pivot := to_local(body_a.to_global(_pivot_on_a))
	draw_line(a, pivot, line_color, 3.0)
	draw_line(b, pivot, line_color, 3.0)
	draw_circle(a, 4.0, line_color)
	draw_circle(b, 4.0, line_color)
	draw_circle(pivot, 7.0, line_color)
	draw_circle(pivot, 3.0, Color.BLACK)
