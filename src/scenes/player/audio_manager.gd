class_name AudioManager
extends Node3D

# NOTE: Exceeding the packet limit causes iroh disconnect!
const MAX_FRAMES_PER_PACKET: int = 512
const INPUT_THRESHOLD: float = 0.005

var bus_index: int = 0
var effect: AudioEffectCapture
var playback: AudioStreamGeneratorPlayback
var receive_buffer: PackedByteArray = PackedByteArray()
var current_sample_rate: int = 48000

@onready var mic_input: AudioStreamPlayer = $MicInput
@onready var mic_output: RaytracedAudioPlayer3D = $MicOutput
@onready var is_steam: bool = multiplayer.multiplayer_peer is SteamMultiplayerPeer
@onready var is_e_net: bool = multiplayer.multiplayer_peer is ENetMultiplayerPeer


func _ready() -> void:
	if not is_multiplayer_authority():
		set_process(false)
	
	if is_e_net:
		bus_index = AudioServer.get_bus_index(&"Record")
		effect = AudioServer.get_bus_effect(bus_index, 0)
		mic_output.stream.mix_rate = current_sample_rate
		playback = mic_output.get_stream_playback()
	elif is_steam:
		current_sample_rate = Steam.getVoiceOptimalSampleRate()
		mic_output.stream.mix_rate = current_sample_rate
		playback = mic_output.get_stream_playback()
		_record_voice(true)


func _process(_delta: float) -> void:
	if is_e_net:
		if effect.can_get_buffer(MAX_FRAMES_PER_PACKET) and playback.can_push_buffer(MAX_FRAMES_PER_PACKET):
			send_voice_data_local.rpc(effect.get_buffer(MAX_FRAMES_PER_PACKET))
		effect.clear_buffer()
	elif is_steam:
		var available_voice: Dictionary = Steam.getAvailableVoice()
		if not available_voice:
			return
		if available_voice['result'] == Steam.VOICE_RESULT_OK and available_voice['buffer'] > 0:
			var voice_data: Dictionary = Steam.getVoice()
			if voice_data['result'] == Steam.VOICE_RESULT_OK and voice_data['written']:
				send_voice_data_steam.rpc(voice_data)


@rpc("any_peer", "call_remote", "unreliable")
func send_voice_data_local(data: PackedVector2Array) -> void:
	for i: int in range(MAX_FRAMES_PER_PACKET):
		playback.push_frame(data[i])


@rpc("any_peer", "call_remote", "unreliable")
func send_voice_data_steam(voice_data: Dictionary) -> void:
	var decompressed_voice: Dictionary = Steam.decompressVoice(voice_data['buffer'], current_sample_rate)
	if decompressed_voice['result'] == Steam.VOICE_RESULT_OK and decompressed_voice['size'] > 0:
		receive_buffer = decompressed_voice['uncompressed']
		receive_buffer.resize(decompressed_voice['size'])
		for i: int in playback.get_frames_available():
			if receive_buffer.is_empty():
				break
			
			var raw_value: int = receive_buffer[0] | (receive_buffer[1] << 8)
			# Make it a 16-bit signed integer
			raw_value = (raw_value + 32768) & 0xffff
			# Convert the 16-bit integer to a float on from -1 to 1
			var amplitude: float = float(raw_value - 32768) / 32768.0
			
			playback.push_frame(Vector2(amplitude, amplitude))
			
			receive_buffer.remove_at(0)
			receive_buffer.remove_at(0)


func _record_voice(is_recording: bool) -> void:
	# If talking, suppress all other audio or voice comms from the Steam UI
	Steam.setInGameVoiceSpeaking(Steam.getSteamID(), is_recording)
	if is_recording:
		Steam.startVoiceRecording()
	else:
		Steam.stopVoiceRecording()
