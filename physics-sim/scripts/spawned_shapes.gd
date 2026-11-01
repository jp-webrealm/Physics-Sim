extends Node2D

var paused: bool = true

@onready var start_button: Button = $"../ui/start button"

func _ready() -> void:
	get_tree().paused = true
	_refresh_start_button()

func _on_start_button_button_up() -> void:
	paused = not paused
	get_tree().paused = paused
	_refresh_start_button()

## removes every shape and joint and pauses, back to how the sim looks on launch
func _on_reset_button_pressed() -> void:
	for slot in get_tree().get_nodes_in_group("joint_slots"):
		slot._set_armed(false)
	var inspector := get_node_or_null("../ui/InspectorPanel")
	if inspector:
		inspector.clear_selection()
	for child in get_children():
		child.queue_free()
	paused = true
	get_tree().paused = true
	_refresh_start_button()

func _refresh_start_button() -> void:
	if start_button == null:
		return
	if paused:
		start_button.text = "Start Simulation"
		start_button.tooltip_text = "Run the simulation"
	else:
		start_button.text = "Stop Simulation"
		start_button.tooltip_text = "Pause the simulation"
