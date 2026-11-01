## settings panel that allows the user to adjust the size and mass of the next shape that will be spawned
extends VBoxContainer
class_name SpawnSettings

@onready var set_size_x: SpinBox = $"x size spinbox"
@onready var set_size_y: SpinBox = $"y size spinbox"
@onready var set_mass: SpinBox = $"mass spinbox"

func _ready() -> void:
	for spin in [set_size_x, set_size_y, set_mass]:
		SpinBoxHelper.select_all_on_focus(spin)


func get_size_x() -> float:
	return set_size_x.value

func get_size_y() -> float:
	return set_size_y.value

func get_mass() -> float:
	return set_mass.value
