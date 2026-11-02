## glues two shapes together
extends ShapeJoint
class_name HardJoint


func _build(_pivot: Vector2) -> void:
	# a single pin lets the bodies spin around it, so a second pin at a different point locks rotation
	var second_point := body_b.global_position
	if body_a.global_position.distance_to(second_point) < 1.0:
		second_point = body_a.global_position + Vector2(20, 0)

	_configure_pin($PinA, body_a.global_position)
	_configure_pin($PinB, second_point)


func _configure_pin(pin: PinJoint2D, at: Vector2) -> void:
	# the pin reads its position when the bodies are assigned, so place it first
	pin.global_position = at
	pin.softness = 0.0
	pin.disable_collision = true
	pin.node_a = body_a.get_path()
	pin.node_b = body_b.get_path()
