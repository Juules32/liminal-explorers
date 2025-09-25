class_name InputSynchronizer
extends MultiplayerSynchronizer

@export var axis_x: float = 0
@export var axis_y: float = 0

func _on_input_enter_tree(pid: int) -> void:
	print("tttee")
	set_multiplayer_authority(pid)

func _physics_process(_delta: float) -> void:
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		axis_x = Input.get_axis("ui_left", "ui_right")
		axis_y = Input.get_axis("ui_up", "ui_down")
		if axis_x:
			print(axis_x)
