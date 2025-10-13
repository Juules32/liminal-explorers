extends VisibleOnScreenNotifier3D

@export var world: World
@export var train_voices: Node3D

var _enabled: bool = false

var _is_in_view: bool = true

# To prevent immediate teleportation
var _has_been_seen: bool = false

# To prevent more than one teleportation
var _has_moved: bool = false


func _ready() -> void:
	Signals.enable_carriage_teleport.connect(_on_enable_carriage_teleport)


func _on_enable_carriage_teleport() -> void:
	_enabled = true


# Constantly update position to match other player position
func _physics_process(_delta: float) -> void:
	if world.other_player:
		global_position = world.other_player.global_position


func _on_screen_entered() -> void:
	if not _enabled:
		return
	
	W.print("Other player entered screen")
	_is_in_view = true
	_has_been_seen = true


func _on_screen_exited() -> void:
	if not _enabled:
		return
	
	W.print("Other player exited screen")
	_is_in_view = false
	
	if _has_been_seen and not _has_moved:
		_verify_other_player_not_in_view.rpc()

# NOTE: call_local is used
@rpc("any_peer", "call_local", "reliable")
func _verify_other_player_not_in_view() -> void:
	if not _is_in_view:
		_move_server_player.rpc()

# NOTE: call_remote is used
@rpc("any_peer", "call_remote", "reliable")
func _move_server_player() -> void:
	if _is_in_view:
		W.print("Not all players not looking")
		return
	
	if not world.server_player:
		W.print("No server player set")
		return
	
	var main_carriage_position: Vector3 = world.main_carriage.to_local(world.server_player.global_position)
	world.server_player.global_position = world.second_carriage.to_global(main_carriage_position)
	world.server_player.input_synchronizer.rotation.y += deg_to_rad(180.0)
	world.server_player.rotation.y -= deg_to_rad(180.0)
	W.print("Moved and rotated server player")
	
	var train_voices_position: Vector3 = world.main_carriage.to_local(train_voices.global_position)
	train_voices.global_position = world.second_carriage.to_global(train_voices_position)
	W.print("Moved and rotated train voices")
	_post_teleport.rpc()

@rpc("any_peer", "call_local", "reliable")
func _post_teleport() -> void:
	_has_moved = true
	Signals.start_second_animation.emit()
