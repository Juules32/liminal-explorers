class_name InputSynchronizer
extends MultiplayerSynchronizer

@export var direction: Vector2 = Vector2()
@export var rotation: Vector3 = Vector3()
@export var interact_raycast: RayCast3D

var mouse_sensitivity: float = 0.002
var controller_sensitivity: float = 0.07

func _ready() -> void:
	if not is_multiplayer_authority():
		set_physics_process(false)
		set_process_input(false)


func _input(event: InputEvent) -> void:
	if not get_window().has_focus():
		return
	
	if event is InputEventMouseMotion:
		# Mouse movement
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.x -= event.relative.y * mouse_sensitivity
		
		# Clamp pitch to prevent flipping
		rotation.x = clamp(rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if event.is_action_pressed("interact"):
		_check_interact()

func _physics_process(_delta: float) -> void:
	if not get_window().has_focus():
		return

	direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var rotation_2d: Vector2 = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	rotation.y -= rotation_2d.x * controller_sensitivity
	rotation.x -= rotation_2d.y * controller_sensitivity


func _check_interact() -> void:
	if not interact_raycast:
		return
	
	if interact_raycast.is_colliding():
		var collider: CollisionObject3D = interact_raycast.get_collider()
		if collider.is_in_group(&"interactible"):
			collider.interact()
