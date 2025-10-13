@icon("res://addons/plenticons/icons/16x/creatures/person-yellow.png")
class_name Player
extends CharacterBody3D

const MOVEMENT_SPEED: float = 8.0
const EAR_HEIGHT: float = 1.174
const PLAYER_EAR: Resource = preload("uid://cpvrqn7dyesuy")

# Authority is set when updating the player id
# so that the multiplayer synchronizer which synchronizes the player id
# will also set authority for all other peers
@export var id: int = -1:
	set(new_id):
		id = new_id
		$AuthorityNode.set_multiplayer_authority(new_id)

@onready var debug_label: Label3D = $DebugLabel
@onready var input_synchronizer: InputSynchronizer = $AuthorityNode/InputSynchronizer
@onready var camera: Camera3D = $CameraPivot/Camera
@onready var authority_node: Node3D = $AuthorityNode
@onready var player_models: Node3D = $PlayerModels
@onready var alice_model: Node3D = $PlayerModels/AliceModel
@onready var bob_model: Node3D = $PlayerModels/BobModel


func _ready() -> void:
	if id == 1:
		alice_model.show()
		bob_model.hide()
	else:
		alice_model.hide()
		bob_model.show()
	
	if authority_node.is_multiplayer_authority():
		camera.make_current()
		var player_ear_instance: PlayerEar = PLAYER_EAR.instantiate()
		add_child(player_ear_instance)
		player_ear_instance.raytraced_audio_listener.make_current()
		player_ear_instance.position.y = EAR_HEIGHT
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if not multiplayer.is_server():
		set_physics_process(false)
	
	Signals.spawned_player.emit(self)


func _physics_process(delta: float) -> void:
	var input_dir: Vector3 = Vector3(input_synchronizer.direction.x, 0, input_synchronizer.direction.y)

	# Rotate input by the player's facing direction
	var direction: Vector3 = (global_transform.basis * input_dir).normalized()

	# Apply speed
	velocity = direction * MOVEMENT_SPEED

	# Apply rotation from synchronizer
	rotation.y = input_synchronizer.rotation.y
	camera.rotation.x = input_synchronizer.rotation.x

	move_and_collide(velocity * delta)
	debug_label.text = str(velocity) + "\n" + str(id) + "\n" + str(global_position)
