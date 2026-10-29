extends TextureRect
@export var shape_scene: PackedScene
## when this is set it makes the preview match the size of the shape that will be spawned
@export var settings: SpawnSettings

func _ready() -> void:
	mouse_entered.connect(func(): modulate = Color(1.5, 1.5, 1.5))
	mouse_exited.connect(func(): modulate = Color.WHITE)
	
func _get_drag_data(_at_position: Vector2) -> Variant:
	if shape_scene == null:
		return null
		
	set_drag_preview(_make_preview())
	return { "scene": shape_scene, "settings": settings }


## builds a preview that reads from settings so it looks like the shape that will be spawned
func _make_preview() -> Control:
	var preview_size := size
	if settings:
		preview_size = Vector2(settings.get_size_x(), settings.get_size_y())

	var preview := Control.new()
	if _spawns_circle():
		preview = EllipsePreview.new()
	else:
		var rect := ColorRect.new()
		rect.modulate.a = 0.6
		preview = rect

	preview.size = preview_size
	preview.position = -preview_size / 2.0
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var wrapper := Control.new()
	wrapper.add_child(preview)
	return wrapper


func _spawns_circle() -> bool:
	var body := shape_scene.instantiate()
	var col := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var is_circle := col != null and col.shape is CircleShape2D
	body.free()
	return is_circle


class EllipsePreview extends Control:
	func _draw() -> void:
		var radius := size / 2.0
		if radius.x <= 0.0 or radius.y <= 0.0:
			return
		draw_set_transform(radius, 0.0, radius)
		draw_circle(Vector2.ZERO, 1.0, Color(1, 1, 1, 0.6))
