class_name Player
extends CharacterBody2D

@onready var label: Label = $Label

var player_id: int = -1

const SPEED: float = 500.0

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	var axis_x: float = Input.get_axis("ui_left", "ui_right")
	var axis_y: float = Input.get_axis("ui_up", "ui_down")
	
	velocity = Vector2(axis_x, axis_y).normalized() * SPEED
	
	
	label.text = str(velocity) + "\n" + str(multiplayer.get_unique_id())
	move_and_collide(velocity * delta)
