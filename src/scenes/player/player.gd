@icon("res://addons/plenticons/icons/16x/creatures/person-yellow.png")

class_name Player
extends CharacterBody3D

const SPEED: float = 14.0

# Authority is set when updating the player id
# so that the multiplayer synchronizer which synchronizes the player id
# will also set authority for all other peers
@export var id: int = -1:
	set(new_id):
		id = new_id
		$AuthorityNode.set_multiplayer_authority(new_id)

@onready var label: Label3D = $Label
@onready var input_synchronizer: InputSynchronizer = $AuthorityNode/InputSynchronizer
@onready var camera: Camera3D = $CameraPivot/Camera
@onready var raytraced_audio_listener: RaytracedAudioListener = $RaytracedAudioListener
@onready var authority_node: Node3D = $AuthorityNode

func _ready() -> void:
	if authority_node.is_multiplayer_authority():
		camera.make_current()
		raytraced_audio_listener.make_current()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		# Remove listeners on players not controlled by this device
		raytraced_audio_listener.queue_free()
	
	if not multiplayer.is_server():
		set_physics_process(false)

func _physics_process(delta: float) -> void:
	var input_dir: Vector3 = Vector3(input_synchronizer.direction.x, 0, input_synchronizer.direction.y)

	# Rotate input by the player's facing direction
	var direction: Vector3 = (global_transform.basis * input_dir).normalized()

	# Apply speed
	velocity = direction * SPEED

	# Apply rotation from synchronizer
	rotation.y = input_synchronizer.rotation.y
	camera.rotation.x = input_synchronizer.rotation.x

	move_and_collide(velocity * delta)
	label.text = str(velocity) + "\n" + str(id)
