class_name Player
extends CharacterBody2D

@onready var label: Label = $Label
@onready var input_synchronizer: MultiplayerSynchronizer = $InputSynchronizer

@export var player_id: int = -1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)

const SPEED: float = 500.0

func connect_enter_tree(pid: int) -> void:
	%InputSynchronizer.tree_entered.connect(_on_input_enter_tree.bind(pid))

func _on_input_enter_tree(_pid: int) -> void:
	print("tttee")
	# %InputSynchronizer.set_multiplayer_authority(pid)

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		velocity = Vector2(input_synchronizer.axis_x, input_synchronizer.axis_y).normalized() * SPEED
		move_and_collide(velocity * delta)

	label.text = str(velocity) + "\n" + str(multiplayer.get_unique_id())
