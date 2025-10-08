class_name AudioManager
extends Node3D

var bus_index: int = 0
var effect: AudioEffectCapture
var playback: AudioStreamGeneratorPlayback
@onready var mic_input: AudioStreamPlayer = $MicInput
@onready var mic_output: RaytracedAudioPlayer3D = $MicOutput
@onready var is_steam: bool = multiplayer.multiplayer_peer is SteamMultiplayerPeer
@onready var is_e_net: bool = multiplayer.multiplayer_peer is ENetMultiplayerPeer

@export var input_threshold: float = 0.005
var receive_buffer: PackedByteArray = PackedByteArray()

var current_sample_rate: int = 48000
var packet_read_limit: int = 5



# NOTE: Exceeding the packet limit causes iroh disconnect!
const MAX_FRAMES_PER_PACKET: int = 512

func _ready() -> void:
	if is_e_net:
		bus_index = AudioServer.get_bus_index(&"Record")
		effect = AudioServer.get_bus_effect(bus_index, 0)
		playback = mic_output.get_stream_playback()
	elif is_steam:
		get_sample_rate()
	
		mic_output.stream.mix_rate = current_sample_rate
		playback = mic_output.get_stream_playback()
		record_voice(true)

func _process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	if is_e_net:
		# NOTE: USEFUL ONLY FOR DEBUGGING. IN PRODUCTION, CLIENTS SHOULD BE ABLE TO SPEAK
		if not multiplayer.is_server():
			return

		if effect.can_get_buffer(MAX_FRAMES_PER_PACKET) and playback.can_push_buffer(MAX_FRAMES_PER_PACKET):
			send_data_local.rpc(effect.get_buffer(MAX_FRAMES_PER_PACKET))
		effect.clear_buffer()
	elif is_steam:
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
				send_data_steam.rpc(voice_data)


@rpc("any_peer", "call_remote", "reliable")
func send_data_local(data: PackedVector2Array) -> void:
	for i: int in range(MAX_FRAMES_PER_PACKET):
		playback.push_frame(data[i])


func get_sample_rate() -> void:
	current_sample_rate = Steam.getVoiceOptimalSampleRate()
	print("Current sample rate: %s" % current_sample_rate)

@rpc("any_peer", "call_remote", "unreliable")
func send_data_steam(voice_data: Dictionary) -> void:
	var decompressed_voice: Dictionary = Steam.decompressVoice(voice_data['buffer'], current_sample_rate)

	if decompressed_voice['result'] == Steam.VOICE_RESULT_OK and decompressed_voice['size'] > 0:
		print("Decompressed voice: %s" % decompressed_voice['size'])

		receive_buffer = decompressed_voice['uncompressed']
		receive_buffer.resize(decompressed_voice['size'])

		# We now iterate through the local_voice_buffer and push the samples to the audio generator
		for i: int in playback.get_frames_available():
			# Steam's audio data is represented as 16-bit single channel PCM audio, so we need to convert it to amplitudes
			# Combine the low and high bits to get full 16-bit value
			if receive_buffer.is_empty():
				break
			 
			var raw_value: int = receive_buffer[0] | (receive_buffer[1] << 8)
			# Make it a 16-bit signed integer
			raw_value = (raw_value + 32768) & 0xffff
			# Convert the 16-bit integer to a float on from -1 to 1
			var amplitude: float = float(raw_value - 32768) / 32768.0

			# push_frame() takes a Vector2. The x represents the left channel and the y represents the right channel
			playback.push_frame(Vector2(amplitude, amplitude))

			# Delete the used samples
			receive_buffer.remove_at(0)
			receive_buffer.remove_at(0)

func record_voice(is_recording: bool) -> void:
	# If talking, suppress all other audio or voice comms from the Steam UI
	Steam.setInGameVoiceSpeaking(Steam.getSteamID(), is_recording)

	if is_recording:
		Steam.startVoiceRecording()
	else:
		Steam.stopVoiceRecording()
