## base for joints that connect two shapes. draws itself between them and
## frees itself when either shape is removed
extends Node2D
class_name ShapeJoint

@export var body_a: PhysicsBody2D
@export var body_b: PhysicsBody2D
@export var line_color := Color(1.0, 1.0, 1.0, 1.0)

var _attached := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if body_a and body_b and not _attached:
		attach(body_a, body_b, body_b.global_position)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if not _attached or not is_instance_valid(body_a) or not is_instance_valid(body_b):
		return
	_draw_joint(to_local(body_a.global_position), to_local(body_b.global_position))



func attach(a: PhysicsBody2D, b: PhysicsBody2D, pivot: Vector2) -> void:
	body_a = a
	body_b = b
	_build(pivot)
	_attached = true

	for body in [a, b]:
		if not body.tree_exiting.is_connected(queue_free):
			body.tree_exiting.connect(queue_free)


## sets up the physics joint nodes once both bodies are known
func _build(_pivot: Vector2) -> void:
	pass


func _draw_joint(a: Vector2, b: Vector2) -> void:
	draw_line(a, b, line_color, 3.0)
	draw_circle(a, 4.0, line_color)
	draw_circle(b, 4.0, line_color)
