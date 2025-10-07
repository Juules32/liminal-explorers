class_name AudioManager
extends Node3D

const SHOULD_RECORD: bool = false

var bus_index: int = 0
var effect: AudioEffectCapture
var playback: AudioStreamGeneratorPlayback
@onready var mic_input: AudioStreamPlayer = $MicInput
@onready var mic_output: RaytracedAudioPlayer3D = $MicOutput

@export var input_threshold: float = 0.005
var receive_buffer: PackedFloat32Array = PackedFloat32Array()

# NOTE: Exceeding the packet limit causes iroh disconnect!
const MAX_FRAMES_PER_PACKET: int = 512

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(&"Record")
	effect = AudioServer.get_bus_effect(bus_index, 0)
	playback = mic_output.get_stream_playback()

func _process(_delta: float) -> void:
	if not SHOULD_RECORD:
		return
	
	# NOTE: USEFUL ONLY FOR DEBUGGING. IN PRODUCTION, CLIENTS SHOULD BE ABLE TO SPEAK
	#if not multiplayer.is_server():
	#	return
	
	if not is_multiplayer_authority():
		return
	if effect.can_get_buffer(MAX_FRAMES_PER_PACKET) and playback.can_push_buffer(MAX_FRAMES_PER_PACKET):
		send_data.rpc(effect.get_buffer(MAX_FRAMES_PER_PACKET))
	effect.clear_buffer()

func process_microphone() -> void:
	var stereo_data: PackedVector2Array = effect.get_buffer(effect.get_frames_available())
	if stereo_data:
		var compressed_data: PackedFloat32Array = PackedFloat32Array()
		compressed_data.resize(stereo_data.size())
		var max_amp: float = 0.0
		for i: int in range(len(stereo_data)):
			var frame_data: float = (stereo_data[i].x + stereo_data[i].y) * 0.5
			max_amp = max(max_amp, frame_data)
			compressed_data[i] = frame_data
		if max_amp < input_threshold:
			return
		
		send_data.rpc(compressed_data)

func process_voice() -> void:
	if receive_buffer.size() == 0:
		return
	
	var frames_to_process: int = min(playback.get_frames_available(), receive_buffer.size())
	for i: int in range(frames_to_process):
		playback.push_frame(Vector2(receive_buffer[i], receive_buffer[i]))
	
	receive_buffer = receive_buffer.slice(frames_to_process)

@rpc("any_peer", "call_remote", "reliable")
func send_data(data: PackedVector2Array) -> void:
	for i: int in range(MAX_FRAMES_PER_PACKET):
		playback.push_frame(data[i])
