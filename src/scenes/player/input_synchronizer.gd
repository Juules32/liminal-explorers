class_name InputSynchronizer
extends MultiplayerSynchronizer

@export var axis_x: float = 0
@export var axis_y: float = 0

@onready var player: Player = $".."


func _physics_process(_delta: float) -> void:
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		axis_x = Input.get_axis("move_left", "move_right")
		axis_y = Input.get_axis("move_forward", "move_back")
		if axis_x:
			print(axis_x)
