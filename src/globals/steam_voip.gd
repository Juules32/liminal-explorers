extends Node

var current_sample_rate: int = 48000
var network_playback: AudioStreamGeneratorPlayback = null
var network_voice_buffer: PackedByteArray = PackedByteArray()
var packet_read_limit: int = 5
var active: bool = false

@onready var network: AudioStreamPlayer = $Network

# Called when the node enters the scene tree for the first time.
func setup() -> void:
	get_sample_rate()
	
	network.stream.mix_rate = current_sample_rate
	network.play()
	network_playback = network.get_stream_playback()

func _process(_delta: float) -> void:
	if not active:
		return
	
	var available_voice: Dictionary = Steam.getAvailableVoice()
	
	if not available_voice:
		return

	# Seems there is voice data
	if available_voice['result'] == Steam.VOICE_RESULT_OK and available_voice['buffer'] > 0:
		# Valve's getVoice uses 1024 but GodotSteam's is set at 8192?
		# Our sizes might be way off; internal GodotSteam notes that Valve suggests 8kb
		# However, this is not mentioned in the header nor the SpaceWar example but -is- in Valve's docs which are usually wrong
		var voice_data: Dictionary = Steam.getVoice()
		if voice_data['result'] == Steam.VOICE_RESULT_OK and voice_data['written']:
			print("Voice message has data: %s / %s" % [voice_data['result'], voice_data['written']])

			# Here we can pass this voice data off on the network
			receive_voice_data.rpc(voice_data)

func get_sample_rate() -> void:
	current_sample_rate = Steam.getVoiceOptimalSampleRate()
	print("Current sample rate: %s" % current_sample_rate)

@rpc("any_peer", "call_local", "unreliable")
func receive_voice_data(voice_data: Dictionary) -> void:
	if not setup:
		return
	
	var decompressed_voice: Dictionary = Steam.decompressVoice(voice_data['buffer'], current_sample_rate)

	if decompressed_voice['result'] == Steam.VOICE_RESULT_OK and decompressed_voice['size'] > 0:
		print("Decompressed voice: %s" % decompressed_voice['size'])

		network_voice_buffer = decompressed_voice['uncompressed']
		network_voice_buffer.resize(decompressed_voice['size'])

		# We now iterate through the local_voice_buffer and push the samples to the audio generator
		for i: int in network_playback.get_frames_available():
			# Steam's audio data is represented as 16-bit single channel PCM audio, so we need to convert it to amplitudes
			# Combine the low and high bits to get full 16-bit value
			if network_voice_buffer.is_empty():
				break
			 
			var raw_value: int = network_voice_buffer[0] | (network_voice_buffer[1] << 8)
			# Make it a 16-bit signed integer
			raw_value = (raw_value + 32768) & 0xffff
			# Convert the 16-bit integer to a float on from -1 to 1
			var amplitude: float = float(raw_value - 32768) / 32768.0

			# push_frame() takes a Vector2. The x represents the left channel and the y represents the right channel
			network_playback.push_frame(Vector2(amplitude, amplitude))

			# Delete the used samples
			network_voice_buffer.remove_at(0)
			network_voice_buffer.remove_at(0)

func record_voice(is_recording: bool) -> void:
	# If talking, suppress all other audio or voice comms from the Steam UI
	Steam.setInGameVoiceSpeaking(Steam.getSteamID(), is_recording)

	if is_recording:
		Steam.startVoiceRecording()
	else:
		Steam.stopVoiceRecording()
