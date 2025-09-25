class_name Player
extends CharacterBody2D

@onready var label: Label = $Label
@onready var input_synchronizer: MultiplayerSynchronizer = $InputSynchronizer

@export var player_id: int = -1

func _init() -> void:
	%InputSynchronizer.tree_entered.connect(_on_input_synchronizer_tree_entered.bind(player_id))

const SPEED: float = 500.0

func _on_input_synchronizer_tree_entered(p_id: int) -> void:
	print(player_id, " ", multiplayer.get_unique_id())
	%InputSynchronizer.set_multiplayer_authority(p_id)

func _ready() -> void:
	if input_synchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		velocity = Vector2(input_synchronizer.axis_x, input_synchronizer.axis_y).normalized() * SPEED
		move_and_collide(velocity * delta)

	label.text = str(velocity) + "\n" + str(multiplayer.get_unique_id())
