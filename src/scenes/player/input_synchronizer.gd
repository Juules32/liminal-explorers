class_name InputSynchronizer
extends MultiplayerSynchronizer

@export var direction: Vector2 = Vector2()
@export var rotation: Vector2 = Vector2()
var mouse_sensitivity: float = 0.002

func _ready() -> void:
	if not is_multiplayer_authority():
		set_physics_process(false)
		set_process_input(false)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Mouse movement
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.x -= event.relative.y * mouse_sensitivity
		
		# Clamp pitch to prevent flipping
		rotation.x = clamp(rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
