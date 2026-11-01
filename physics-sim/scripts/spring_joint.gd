## connects two shapes with a spring that pulls them back to the distance they started at
extends ShapeJoint

## how hard the spring pulls back when stretched or squished
@export var stiffness: float = 20.0
## how quickly the bouncing dies down
@export var damping: float = 1.0
@export var coils: int = 8


func _build(_pivot: Vector2) -> void:
	var spring := $Spring as DampedSpringJoint2D
	var from := body_a.global_position
	var to := body_b.global_position
	var length := maxf(from.distance_to(to), 1.0)

	# the spring runs from its origin along its local +Y axis for `length` pixels,
	# and it reads that layout when the bodies are assigned, so place it first
	spring.global_position = from
	spring.global_rotation = (to - from).angle() - PI / 2.0
	spring.length = length
	spring.rest_length = length
	spring.stiffness = stiffness
	spring.damping = damping
	spring.disable_collision = false
	spring.node_a = body_a.get_path()
	spring.node_b = body_b.get_path()


func _draw_joint(a: Vector2, b: Vector2) -> void:
	draw_circle(a, 4.0, line_color)
	draw_circle(b, 4.0, line_color)
	var length := a.distance_to(b)
	if length < 1.0:
		return

	var along := (b - a) / length
	var side := Vector2(-along.y, along.x) * 6.0
	var end_gap := minf(10.0, length * 0.2)
	var start := a + along * end_gap
	var finish := b - along * end_gap

	var points := PackedVector2Array([a, start])
	for i in coils:
		var t := (float(i) + 0.5) / float(coils)
		var flip := 1.0 if i % 2 == 0 else -1.0
		points.append(start.lerp(finish, t) + side * flip)
	points.append(finish)
	points.append(b)
	draw_polyline(points, line_color, 2.0)
