class_name AudioManager
extends Node

var bus_index: int = 0
var effect: AudioEffectCapture
var playback: AudioStreamGeneratorPlayback
@onready var mic_input: AudioStreamPlayer = $MicInput
@onready var mic_output: AudioStreamPlayer2D = $MicOutput
@export var input_threshold: float = 0.005
var receive_buffer: PackedFloat32Array = PackedFloat32Array()

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(&"Record")
	effect = AudioServer.get_bus_effect(bus_index, 0)
	playback = mic_output.get_stream_playback()

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		process_microphone()
	process_voice()

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

@rpc("any_peer", "call_remote", "unreliable")
func send_data(compressed_data: PackedFloat32Array) -> void:
	receive_buffer.append_array(compressed_data)
