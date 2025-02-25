extends AudioStreamPlayer3D

var SAMPLE_RATE = 44100
var BUFFER_SIZE = 512

var phases = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

# Firing order (1–5–3–6–2–4) means we offset each cylinder's angle
# in the 720° cycle of a 4-stroke. We'll store fractional offsets [0..1].
var firing_order_offsets = [0.0, 0.3333, 0.1667, 0.8333, 0.5, 0.6667]

@onready var engine_stream = AudioStreamGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	engine_stream.mix_rate = SAMPLE_RATE
	engine_stream.buffer_length = 0.5  # Half a second of buffering
	self.stream = engine_stream
	self.play()

func generate_engine_audio(rpm: float, delta: float) -> void:
	var playback = self.get_stream_playback()
	if not (playback is AudioStreamGeneratorPlayback):
		return
	
	var frames_to_generate = BUFFER_SIZE
	var rev_per_sec = rpm / 60.0
	var cylinder_fire_freq = rev_per_sec / 2.0
	
	var audio_buffer = PackedVector2Array()
	audio_buffer.resize(frames_to_generate)
	
	var phase_increment = 2.0 * PI * cylinder_fire_freq / float(SAMPLE_RATE)
	
	for i in range(frames_to_generate):
		var sample = 0.0
		for c in range(6):
			phases[c] += phase_increment
			if phases[c] > 2.0 * PI:
				phases[c] -= 2.0 * PI
			var offset_phase = phases[c] + 2.0 * PI * firing_order_offsets[c]
			var impulse = sin(offset_phase)
			
			if impulse > 0.99:
				sample += 0.3
		
		sample = clamp(sample, -1.0, 1.0)
		audio_buffer[i] = Vector2(sample, sample)
	
	playback.push_buffer(audio_buffer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
