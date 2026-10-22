extends Control

@export var bounce_slider: HSlider
@export var friction_slider: HSlider
@export var rough_button: CheckButton
@export var absorbent_button: CheckButton

func get_physics_material() -> PhysicsMaterial:
	var material: PhysicsMaterial = PhysicsMaterial.new()
	material.bounce = bounce_slider.value
	material.friction = friction_slider.value
	material.rough = rough_button.button_pressed
	material.absorbent = absorbent_button.button_pressed
	return material
