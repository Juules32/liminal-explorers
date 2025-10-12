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
@onready var player_vision_teleporter: PlayerVisionTeleporter = $PlayerVisionTeleporter

func _ready() -> void:
	if authority_node.is_multiplayer_authority():
		camera.make_current()
		raytraced_audio_listener.make_current()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Signals.move_player_carriage_teleport.connect(_on_move_player_carriage_teleport)
	else:
		player_vision_teleporter.screen_entered.connect(player_vision_teleporter._on_screen_entered)
		player_vision_teleporter.screen_exited.connect(player_vision_teleporter._on_screen_exited)

		# Remove listeners on players not controlled by this device
		raytraced_audio_listener.queue_free()
	if not multiplayer.is_server():
		set_physics_process(false)


# ISSUES: 1. Non server node positions aren't updated because of the multiplayer synchronizer
# 2. It doesn't check whether both players aren't looking at each other
# Update: the ones the vision nodes trigger on are always those for whom:
# id != multiplayer.get_unique_id()
# TODO: Make the vision detectors only be on authority == unique_id node and
# constantly move it to fit player two's direction
func _on_move_player_carriage_teleport(main_carriage: Node3D, second_carriage: Node3D) -> void:
	if not multiplayer.is_server():
		return
	W.print("moving player")
	var main_carriage_position: Vector3 = main_carriage.to_local(self.global_position)
	print(deg_to_rad(180.0) - self.input_synchronizer.rotation.y)
	print(self.input_synchronizer.rotation)
	print(self.global_position)
	self.global_position = second_carriage.to_global(main_carriage_position)
	self.input_synchronizer.rotation.y -= deg_to_rad(180.0)
	self.rotation.y -= deg_to_rad(180.0)
	print(self.global_position)
	#input_synchronizer.rotation.y += deg_to_rad(180)


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
	label.text = str(velocity) + "\n" + str(id) + "\n" + str(global_position)
