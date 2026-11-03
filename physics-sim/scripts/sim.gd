## Autoload named "Sim" (Project Settings > Globals > Autoload).
## Holds the selected shape and every global setting the side menu edits.
## Audio, screen shake, gravity and the arrow editor all read from here.
extends Node

signal selection_changed(shape: Shape)

var selected: Shape = null

## 1.0 = real time. The Start/Stop button is still the pause control
var time_scale := 1.0:
	set(value):
		time_scale = clampf(value, 0.1, 4.0)
		Engine.time_scale = time_scale

var gravity := 980.0:
	set(value):
		gravity = maxf(value, 0.0)
		_apply_gravity()

## degrees, 90 = straight down
var gravity_angle := 90.0:
	set(value):
		gravity_angle = fposmod(value, 360.0)
		_apply_gravity()

var shake_intensity := 1.0
var audio_muted := false
var audio_volume := 0.6
## speed (px/s) that reaches the highest note
var audio_pitch_range := 1200.0
## 0 = mono, 1 = full left/right placement
var audio_spatial := 1.0
## how far pitch leads the speed when accelerating
var audio_bend := 0.5

## sum of (energy before - energy after) for every shape touching something.
## shapes add to it each physics step, the screen shake reads and clears it
var energy_delta := 0.0

var _palette_dirty := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)
	var dir: Vector2 = ProjectSettings.get_setting("physics/2d/default_gravity_vector", Vector2.DOWN)
	gravity_angle = rad_to_deg(dir.angle())


func _process(_delta: float) -> void:
	if _palette_dirty:
		_palette_dirty = false
		ShapePalette.refresh(get_tree())


## click a shape while paused to select it. arrow_editor.gd runs first and swallows
## clicks on the selected shape's own arrows
func _unhandled_input(event: InputEvent) -> void:
	if not get_tree().paused:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var world_pos: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * event.position
		for node in get_tree().get_nodes_in_group("shapes"):
			if node is Shape and node.contains_point(world_pos):
				select(node)
				return
		clear_selection()


func select(shape: Shape) -> void:
	if shape == selected:
		return
	selected = shape
	selection_changed.emit(shape)


func clear_selection() -> void:
	select(null)


func request_palette_refresh() -> void:
	_palette_dirty = true


func consume_energy_loss() -> float:
	var lost := maxf(energy_delta, 0.0)
	energy_delta = 0.0
	return lost


func _apply_gravity() -> void:
	if not is_inside_tree():
		return
	var space := get_viewport().find_world_2d().space
	PhysicsServer2D.area_set_param(space, PhysicsServer2D.AREA_PARAM_GRAVITY, gravity)
	PhysicsServer2D.area_set_param(space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR,
		Vector2.from_angle(deg_to_rad(gravity_angle)))
	# resting bodies are asleep and would ignore the change
	get_tree().call_group("shapes", "set_sleeping", false)
