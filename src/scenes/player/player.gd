@icon("res://addons/plenticons/icons/16x/creatures/person-yellow.png")

class_name Player
extends CharacterBody2D

@onready var label: Label = $Label
@onready var input_synchronizer: MultiplayerSynchronizer = $InputSynchronizer

@export var player_id: int = -1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)
		%AudioManager.set_multiplayer_authority(id)

const SPEED: float = 500.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		velocity = Vector2(input_synchronizer.axis_x, input_synchronizer.axis_y).normalized() * SPEED
		move_and_collide(velocity * delta)

	label.text = str(velocity) + "\n" + str(multiplayer.get_unique_id())
