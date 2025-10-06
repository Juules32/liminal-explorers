@icon("res://addons/plenticons/icons/16x/creatures/person-yellow.png")

class_name Player
extends CharacterBody3D

@onready var label: Label3D = $Label
@onready var input_synchronizer: MultiplayerSynchronizer = $InputSynchronizer
@onready var camera_3d: Camera3D = $CameraPivot/Camera3D
@onready var audio_listener_3d: RaytracedAudioListener = $AudioListener3D

@export var player_id: int = -1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)
		%AudioManager.set_multiplayer_authority(id)

const SPEED: float = 14.0

func _ready() -> void:
	if multiplayer.get_unique_id() == player_id:
		camera_3d.make_current()
		audio_listener_3d.make_current()

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		velocity = Vector3(input_synchronizer.axis_x, 0, input_synchronizer.axis_y).normalized() * SPEED
		move_and_collide(velocity * delta)

	label.text = str(velocity) + "\n" + str(multiplayer.get_unique_id())
