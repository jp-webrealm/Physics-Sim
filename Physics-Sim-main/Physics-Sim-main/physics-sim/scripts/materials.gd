extends VBoxContainer

@export var bounce_slider: HSlider
@export var friction_slider: HSlider
@export var rough_button: CheckButton
@export var absorbent_button: CheckButton
@export var bounce_value: Label
@export var friction_value: Label

func _ready() -> void:
	if bounce_slider == null or friction_slider == null:
		return
	bounce_slider.value_changed.connect(_on_bounce_changed)
	friction_slider.value_changed.connect(_on_friction_changed)
	_on_bounce_changed(bounce_slider.value)
	_on_friction_changed(friction_slider.value)

func _on_bounce_changed(value: float) -> void:
	if bounce_value:
		bounce_value.text = "%.2f" % value

func _on_friction_changed(value: float) -> void:
	if friction_value:
		friction_value.text = "%.2f" % value

func get_physics_material() -> PhysicsMaterial:
	var material := PhysicsMaterial.new()
	material.bounce = bounce_slider.value
	material.friction = friction_slider.value
	material.rough = rough_button.button_pressed
	material.absorbent = absorbent_button.button_pressed
	return material
