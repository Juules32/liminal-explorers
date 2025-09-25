class_name Player
extends CharacterBody2D

@onready var label: Label = $Label
@onready var input_synchronizer: MultiplayerSynchronizer = $InputSynchronizer

var player_id: int = -1

const SPEED: float = 500.0

@export var axis_x: float = 0
@export var axis_y: float = 0

func _enter_tree() -> void:
	input_synchronizer.set_multiplayer_authority(player_id)

func _physics_process(delta: float) -> void:
	#if not is_multiplayer_authority():
	#	return
	
	axis_x = Input.get_axis("ui_left", "ui_right")
	axis_y = Input.get_axis("ui_up", "ui_down")
	
	velocity = Vector2(axis_x, axis_y).normalized() * SPEED
	
	
	label.text = str(velocity) + "\n" + str(multiplayer.get_unique_id())
	move_and_collide(velocity * delta)
