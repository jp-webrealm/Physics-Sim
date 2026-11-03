## "Senses" tab: audio and screen shake settings
class_name SensesPanel
extends VBoxContainer


func _ready() -> void:
	add_theme_constant_override("separation", 12)

	UIKit.header(self, "Audio")
	UIKit.caption(self, "Speed sets the pitch, acceleration bends it, mass sets loudness, and horizontal position places the sound left to right. Use headphones.")
	UIKit.check(self, "Mute", Sim.audio_muted, func(on: bool) -> void: Sim.audio_muted = on)
	UIKit.slider(self, "Volume", 0.0, 1.0, 0.05, Sim.audio_volume,
		func(v: float) -> void: Sim.audio_volume = v)
	UIKit.slider(self, "Pitch range", 200.0, 3000.0, 50.0, Sim.audio_pitch_range,
		func(v: float) -> void: Sim.audio_pitch_range = v, "%.0f px/s",
		"The speed that reaches the highest note. Lower = more sensitive")
	UIKit.slider(self, "Stereo width", 0.0, 1.0, 0.05, Sim.audio_spatial,
		func(v: float) -> void: Sim.audio_spatial = v, "%.2f",
		"0 is mono, 1 places sounds fully left or right")
	UIKit.slider(self, "Acceleration bend", 0.0, 1.0, 0.05, Sim.audio_bend,
		func(v: float) -> void: Sim.audio_bend = v, "%.2f",
		"How much the pitch slides ahead while a shape speeds up or slows down")

	UIKit.separator(self)

	UIKit.header(self, "Screen shake")
	UIKit.caption(self, "Collisions shake the world in proportion to the energy they destroy. Bouncy, elastic hits barely shake.")
	UIKit.slider(self, "Intensity", 0.0, 2.0, 0.05, Sim.shake_intensity,
		func(v: float) -> void: Sim.shake_intensity = v, "%.2f",
		"0 turns shake off")
