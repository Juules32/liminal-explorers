extends VisibleOnScreenNotifier3D

@export var world: World
@export var train_voices: Node3D

var _enabled: bool = false

var _is_in_view: bool = true

# To prevent immediate teleportation
var _has_been_seen: bool = false

# To prevent more than one teleportation
var _has_moved: bool = false

# Player to move (the player with id == 1 on the server)
var _server_player: Player

# The player not controlled
var _other_player: Player


func _ready() -> void:
	Signals.spawned_player.connect(_on_spawned_player)
	Signals.enable_carriage_teleport.connect(_on_enable_carriage_teleport)


# Update player references when a new player is instantiated
func _on_spawned_player(player: Player) -> void:
	if len(multiplayer.get_peers()) and player.id == multiplayer.get_peers().get(0):
		_other_player = player
	if multiplayer.is_server() and player.id == 1:
		_server_player = player


func _on_enable_carriage_teleport() -> void:
	_enabled = true


# Constantly update position to match other player position
func _physics_process(_delta: float) -> void:
	if _other_player:
		global_position = _other_player.global_position


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
	
	if not _server_player:
		W.print("No server player set")
		return
	
	var main_carriage_position: Vector3 = world.main_carriage.to_local(_server_player.global_position)
	_server_player.global_position = world.second_carriage.to_global(main_carriage_position)
	_server_player.input_synchronizer.rotation.y += deg_to_rad(180.0)
	_server_player.rotation.y -= deg_to_rad(180.0)
	W.print("Moved and rotated server player")
	
	var train_voices_position: Vector3 = world.main_carriage.to_local(train_voices.global_position)
	train_voices.global_position = world.second_carriage.to_global(train_voices_position)
	W.print("Moved and rotated train voices")
	_post_teleport.rpc()

@rpc("any_peer", "call_local", "reliable")
func _post_teleport() -> void:
	_has_moved = true
	Signals.start_second_animation.emit()
