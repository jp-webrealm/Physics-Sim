##full screen control node that accepts drag and drop shapes from the hotbar
extends Control

@export var spawn_parent: Node2D
@export var settings: SpawnSettings

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("scene")

##  godot callback function when user releases their mouse after grabbing a control node
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var body := (data["scene"] as PackedScene).instantiate() as RigidBody2D
	body.global_position = spawn_parent.get_global_mouse_position()
	var panel := settings
	if data.has("settings") and data["settings"] is SpawnSettings:
		panel = data["settings"]
	_apply_settings(body, panel)
	spawn_parent.add_child(body)


## reads the current values from the settings panel and applies them to the next shape
func _apply_settings(body: RigidBody2D, panel: SpawnSettings) -> void:
	if panel == null:
		return

	var new_size := Vector2(panel.get_size_x(), panel.get_size_y())
	var new_mass := panel.get_mass()

	# rigid body requires at least a positive mass
	body.mass = maxf(new_mass, 0.001)

	# shapes are shared between instances, so duplicate before resizing
	var col := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col and col.shape is RectangleShape2D:
		var rect := col.shape.duplicate() as RectangleShape2D
		rect.size = new_size
		col.shape = rect
		col.scale = Vector2.ONE
	elif col and col.shape is CircleShape2D:
		_apply_circle_size(body, col, new_size)

	# keeps the visual centered on the body like it is in square.tscn
	var visual := body.get_node_or_null("ColorRect") as ColorRect
	if visual:
		visual.position = -new_size / 2.0
		visual.size = new_size


## scales circle svg sprite to the same size as collision box 
func _apply_circle_size(body: RigidBody2D, col: CollisionShape2D, new_size: Vector2) -> void:
	var circle := col.shape.duplicate() as CircleShape2D
	var old_diameter := Vector2(circle.radius, circle.radius) * 2.0 * col.scale
	var sprite := body.get_node_or_null("Sprite2D") as Sprite2D
	if sprite and old_diameter.x > 0.0 and old_diameter.y > 0.0:
		sprite.scale *= new_size / old_diameter
	circle.radius = 1.0
	col.shape = circle
	col.scale = new_size / 2.0
