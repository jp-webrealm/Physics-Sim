## glues two shapes together so they move as one, with no give or rotation between them
extends Node2D
class_name HardJoint

@export var body_a: PhysicsBody2D
@export var body_b: PhysicsBody2D

var _attached := false


func _ready() -> void:
	if body_a and body_b and not _attached:
		attach(body_a, body_b)


## both bodies must already be in the tree, since pins lock in the offsets they have right now
func attach(a: PhysicsBody2D, b: PhysicsBody2D) -> void:
	body_a = a
	body_b = b

	# a single pin lets the bodies spin around it, so a second pin at a different point locks rotation
	var second_point := b.global_position
	if a.global_position.distance_to(second_point) < 1.0:
		second_point = a.global_position + Vector2(20, 0)

	_configure_pin($PinA, a.global_position)
	_configure_pin($PinB, second_point)
	_attached = true

	for body in [a, b]:
		if not body.tree_exiting.is_connected(queue_free):
			body.tree_exiting.connect(queue_free)


func _configure_pin(pin: PinJoint2D, at: Vector2) -> void:
	# the pin reads its position when the bodies are assigned, so place it first
	pin.global_position = at
	pin.softness = 0.0
	pin.disable_collision = true
	pin.node_a = body_a.get_path()
	pin.node_b = body_b.get_path()
