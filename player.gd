class_name Player
extends CharacterBody2D

@onready var label: Label = $Label
@onready var input_synchronizer: MultiplayerSynchronizer = $InputSynchronizer

@export var player_id: int = -1

func _enter_tree() -> void:
	%InputSynchronizer.set_multiplayer_authority(player_id)

const SPEED: float = 500.0

@export var axis_x: float = 0
@export var axis_y: float = 0

func _ready() -> void:
	if input_synchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _physics_process(delta: float) -> void:
	print(get_multiplayer_authority(), player_id)
	if not multiplayer.is_server():
		return
	
	axis_x = Input.get_axis("ui_left", "ui_right")
	axis_y = Input.get_axis("ui_up", "ui_down")
	
	velocity = Vector2(axis_x, axis_y).normalized() * SPEED
	
	
	label.text = str(velocity) + "\n" + str(multiplayer.get_unique_id())
	move_and_collide(velocity * delta)
