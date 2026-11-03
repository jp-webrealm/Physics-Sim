## Turns the simulation into sound. One sine voice per shape, mixed into a single generator stream.
##   velocity     -> pitch (log scale, 110 Hz to 1760 Hz)
##   acceleration -> pitch bend (pitch leads the speed, so speeding up slides upward)
##   mass         -> loudness (by mass percentile)
##   x position   -> binaural placement: interaural time + level difference (best on headphones)
## Add as a plain Node named "SenseAudio" in the main scene.
class_name SenseAudio
extends Node

const MIX_RATE := 22050
## only the loudest voices play, keeps the per-sample GDScript loop cheap
const MAX_VOICES := 8
const F_MIN := 110.0
const F_MAX := 1760.0
## horizontal extent of the playfield (matches ruler.gd)
const WORLD_X_MIN := 52.0
const WORLD_X_MAX := 1872.0
const HEAD_RADIUS := 0.0875
const SPEED_OF_SOUND := 343.0
## below this apparent speed a shape is silent, it fades in up to FULL_SPEED
const SILENT_SPEED := 2.0
const FULL_SPEED := 40.0
const PITCH_GLIDE := 0.05
const AMP_GLIDE := 0.04
const PAN_GLIDE := 0.05
const VOICE_GAIN := 0.22


class Voice:
	var phase := 0.0
	var freq := 110.0
	var amp := 0.0
	var az := 0.0
	var t_freq := 110.0
	var t_amp := 0.0
	var t_az := 0.0


var _player: AudioStreamPlayer
var _playback: AudioStreamGeneratorPlayback
var _voices := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = MIX_RATE
	gen.buffer_length = 0.08
	_player = AudioStreamPlayer.new()
	_player.stream = gen
	_player.volume_db = -3.0
	add_child(_player)
	_player.play()
	_playback = _player.get_stream_playback() as AudioStreamGeneratorPlayback


func _process(_delta: float) -> void:
	if _playback == null:
		return
	var frames := _playback.get_frames_available()
	if frames < 64:
		return
	var dt := float(frames) / MIX_RATE
	_update_targets()

	var buf := PackedVector2Array()
	buf.resize(frames)
	for id in _voices.keys():
		var v: Voice = _voices[id]
		_render_voice(v, buf, frames, dt)
		if v.amp < 0.0005 and v.t_amp <= 0.0:
			_voices.erase(id)
	# soft clip so a pile of loud shapes never hard-clips
	for i in frames:
		var s := buf[i]
		buf[i] = Vector2(tanh(s.x), tanh(s.y))
	_playback.push_buffer(buf)


func _update_targets() -> void:
	for v in _voices.values():
		v.t_amp = 0.0
	if Sim.audio_muted or get_tree().paused:
		return

	var ts := Engine.time_scale
	var candidates: Array = []
	for node in get_tree().get_nodes_in_group("shapes"):
		var s := node as Shape
		if s == null or s.frozen:
			continue
		var speed := s.linear_velocity.length()
		var along := 0.0
		if speed > 1.0:
			along = s.accel.dot(s.linear_velocity / speed)
		# what you'd actually perceive: slow motion lowers pitch, bend leads the speed
		var heard := maxf(speed * ts + Sim.audio_bend * along * ts * ts * 0.15, 0.0)
		var gate := smoothstep(SILENT_SPEED, FULL_SPEED, speed * ts)
		var amp := VOICE_GAIN * Sim.audio_volume * lerpf(0.2, 1.0, s.mass_percentile) * gate
		if amp <= 0.0:
			continue
		candidates.append({"shape": s, "amp": amp, "heard": heard})

	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["amp"] > b["amp"])
	for i in mini(candidates.size(), MAX_VOICES):
		var c: Dictionary = candidates[i]
		var shape: Shape = c["shape"]
		var id := shape.get_instance_id()
		var v: Voice = _voices.get(id)
		if v == null:
			v = Voice.new()
			v.freq = _freq_for(c["heard"])
			v.az = _azimuth(shape.global_position.x)
			_voices[id] = v
		v.t_amp = c["amp"]
		v.t_freq = _freq_for(c["heard"])
		v.t_az = _azimuth(shape.global_position.x)


func _freq_for(heard_speed: float) -> float:
	var t := clampf(heard_speed / Sim.audio_pitch_range, 0.0, 1.0)
	return F_MIN * pow(F_MAX / F_MIN, t)


## -PI/2 (hard left) to PI/2 (hard right)
func _azimuth(x: float) -> float:
	var nx := clampf((x - WORLD_X_MIN) / (WORLD_X_MAX - WORLD_X_MIN) * 2.0 - 1.0, -1.0, 1.0)
	return nx * PI * 0.5 * Sim.audio_spatial


## level difference between the ears (x = left, y = right), equal power
func _gains(az: float) -> Vector2:
	var theta := (az + PI * 0.5) * 0.5
	return Vector2(maxf(cos(theta), 0.12), maxf(sin(theta), 0.12))


## half the interaural phase offset for this pitch (Woodworth time difference)
func _half_phase(az: float, freq: float) -> float:
	var itd := HEAD_RADIUS / SPEED_OF_SOUND * (az + sin(az))
	return clampf(TAU * freq * itd * 0.5, -1.2, 1.2)


func _render_voice(v: Voice, buf: PackedVector2Array, frames: int, dt: float) -> void:
	var f1 := lerpf(v.freq, v.t_freq, 1.0 - exp(-dt / PITCH_GLIDE))
	var a1 := lerpf(v.amp, v.t_amp, 1.0 - exp(-dt / AMP_GLIDE))
	var az1 := lerpf(v.az, v.t_az, 1.0 - exp(-dt / PAN_GLIDE))

	# everything ramps linearly across the chunk so nothing clicks
	var inv := 1.0 / float(frames)
	var g0 := _gains(v.az)
	var g1 := _gains(az1)
	var p0 := _half_phase(v.az, v.freq)
	var p1 := _half_phase(az1, f1)
	var df := (f1 - v.freq) * inv
	var da := (a1 - v.amp) * inv
	var dgl := (g1.x - g0.x) * inv
	var dgr := (g1.y - g0.y) * inv
	var dp := (p1 - p0) * inv

	var f := v.freq
	var a := v.amp
	var gl := g0.x
	var gr := g0.y
	var off := p0
	var phase := v.phase
	var step := TAU / MIX_RATE
	for i in frames:
		f += df
		a += da
		gl += dgl
		gr += dgr
		off += dp
		phase += f * step
		if phase > TAU:
			phase -= TAU
		var s := buf[i]
		# source on the right: right ear hears it earlier (phase ahead)
		s.x += sin(phase - off) * a * gl
		s.y += sin(phase + off) * a * gr
		buf[i] = s

	v.phase = phase
	v.freq = f1
	v.amp = a1
	v.az = az1
