## Holds a stack of graphs and points them all at the same shape.
## Call set_shape() (or connect the inspector's shape_selected signal to it).
extends VBoxContainer
class_name GraphPanel

func _ready() -> void:
	# don't block clicks on shapes behind the panel
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# colors match the velocity / acceleration arrows in shape.gd
	_add_graph("Velocity X", Color(0.418, 0.602, 1.0),
		func(s: Shape) -> float: return s.linear_velocity.x)
	_add_graph("Velocity Y", Color(0.571, 0.271, 0.651, 1.0),
		func(s: Shape) -> float: return s.linear_velocity.y)
	_add_graph("Acceleration", Color(1.0, 0.339, 0.273),
		func(s: Shape) -> float: return s.accel.length())
	_add_graph("Kinetic energy", Color(0.4, 0.9, 0.5),
		func(s: Shape) -> float: return 0.5 * s.mass * s.linear_velocity.length_squared())

func _add_graph(title: String, color: Color, getter: Callable) -> void:
	var graph := GraphPlot.new()
	graph.title = title
	graph.line_color = color
	graph.value_getter = getter
	add_child(graph)

func set_shape(shape: Shape) -> void:
	for child in get_children():
		if child is GraphPlot:
			child.shape = shape
