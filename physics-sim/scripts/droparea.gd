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
	_apply_settings(body)
	spawn_parent.add_child(body)


## reads the current values from the settings panel and applies them to the next shape
func _apply_settings(body: RigidBody2D) -> void:
	if settings == null:
		return

	var new_size := Vector2(settings.get_size_x(), settings.get_size_y())
	var new_mass := settings.get_mass()

	# rigid body requires at least a positive mass
	body.mass = maxf(new_mass, 0.001)

	# the RectangleShape2D hitbox has to be duplicated before resizing or every square on screen would change too
	var col := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col and col.shape is RectangleShape2D:
		var rect := col.shape.duplicate() as RectangleShape2D
		rect.size = new_size
		col.shape = rect
		col.scale = Vector2.ONE

	# keeps the visual centered on the body like it is in square.tscn
	var visual := body.get_node_or_null("ColorRect") as ColorRect
	if visual:
		visual.position = -new_size / 2.0
		visual.size = new_size
