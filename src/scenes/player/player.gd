@icon("res://addons/plenticons/icons/16x/creatures/person-yellow.png")

class_name Player
extends CharacterBody3D

@export var id: int = -1:
	set(new_id):
		id = new_id
		$AuthorityNode.set_multiplayer_authority(new_id)

@onready var label: Label3D = $Label
@onready var input_synchronizer: InputSynchronizer = $AuthorityNode/InputSynchronizer
@onready var camera: Camera3D = $CameraPivot/Camera
@onready var raytraced_audio_listener: RaytracedAudioListener = $RaytracedAudioListener

const SPEED: float = 14.0

func _ready() -> void:
	if multiplayer.get_unique_id() == id:
		camera.make_current()
		raytraced_audio_listener.make_current()


func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		velocity = Vector3(input_synchronizer.axis_x, 0, input_synchronizer.axis_y).normalized() * SPEED
		move_and_collide(velocity * delta)
		label.text = str(velocity) + "\n" + str(id)
