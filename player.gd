class_name Player
extends CharacterBody2D

@onready var label: Label = $Label
@onready var input_synchronizer: MultiplayerSynchronizer = $InputSynchronizer

@export var player_id: int = -1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)

const SPEED: float = 500.0

@export var axis_x: float = 0
@export var axis_y: float = 0

func _physics_process(delta: float) -> void:
	#if not is_multiplayer_authority():
	#	return
	
	axis_x = Input.get_axis("ui_left", "ui_right")
	axis_y = Input.get_axis("ui_up", "ui_down")
	
	velocity = Vector2(axis_x, axis_y).normalized() * SPEED
	
	
	label.text = str(velocity) + "\n" + str(multiplayer.get_unique_id())
	move_and_collide(velocity * delta)
