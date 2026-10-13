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
	return { "scene": shape_scene }


## builds a preview that reads from settings so it looks like the shape that will be spawned
func _make_preview() -> Control:
	var preview_size := size
	if settings:
		preview_size = Vector2(settings.get_size_x(), settings.get_size_y())


	var preview := ColorRect.new()
	preview.size = preview_size
	preview.position = -preview_size / 2.0
	preview.modulate.a = 0.6

	var wrapper := Control.new()
	wrapper.add_child(preview)
	return wrapper
