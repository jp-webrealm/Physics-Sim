extends RigidBody2D

class_name Shape

@export var shape_size_x: int = 50
@export var shape_size_y: int = 50

@export var shape_weight: int = 50

@export var shape_color: Color = Color.WHITE
func _ready() -> void:
	$Polygon2D.color = shape_color
