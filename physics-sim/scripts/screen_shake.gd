## Shakes the world (not the UI) when shapes lose energy in collisions.
## Add a Camera2D named "ScreenShake" to the main scene and attach this script.
## Shake size follows sqrt(energy lost), so a hard hit is clearly bigger than a tap
## without a heavy shape maxing it out every time.
class_name ScreenShake
extends Camera2D

const MAX_OFFSET := 28.0
## sqrt(energy lost) that gives a full-strength shake at intensity 1
const FULL_SHAKE_SQRT_ENERGY := 3000.0
## ignore tiny losses from resting contact
const MIN_ENERGY := 2000.0
const DECAY_PER_SECOND := 2.0

var _trauma := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# top-left anchor makes this camera behave exactly like having no camera at all
	anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	position_smoothing_enabled = false
	make_current()


func _physics_process(_delta: float) -> void:
	var lost := Sim.consume_energy_loss()
	if lost > MIN_ENERGY:
		_trauma = minf(_trauma + sqrt(lost) / FULL_SHAKE_SQRT_ENERGY * Sim.shake_intensity, 1.0)


func _process(delta: float) -> void:
	# decay in real time, even when the sim is slowed down
	var real_dt := delta / maxf(Engine.time_scale, 0.01)
	_trauma = maxf(_trauma - DECAY_PER_SECOND * real_dt, 0.0)
	if _trauma > 0.0:
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * MAX_OFFSET * _trauma
	else:
		offset = Vector2.ZERO
