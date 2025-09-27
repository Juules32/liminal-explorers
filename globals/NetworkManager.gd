extends Node

enum MULTIPLAYER_NETWORK_TYPE { ENET, STEAM }
const PLAYER: Resource = preload("uid://c4qhceyy2snhx")

var active_network_type: MULTIPLAYER_NETWORK_TYPE = MULTIPLAYER_NETWORK_TYPE.ENET
var enet_network_scene: Resource = preload("res://enet_network.tscn")
var steam_network_scene: Resource = preload("res://steam_network.tscn")
var active_network: AbstractNetwork

func _build_multiplayer_network() -> void:
	if not active_network:
		print("Setting active_network")
		
		match active_network_type:
			MULTIPLAYER_NETWORK_TYPE.ENET:
				print("Setting network type to ENet")
				_set_active_network(enet_network_scene)
			MULTIPLAYER_NETWORK_TYPE.STEAM:
				print("Setting network type to Steam")
				_set_active_network(steam_network_scene)
			_:
				print("No match for network type!")

func _set_active_network(network_scene: Resource) -> void:
	var network_scene_initialized: AbstractNetwork = network_scene.instantiate()
	active_network = network_scene_initialized
	
	for child: Node in get_children():
		child.queue_free()
	
	# Necessary for signals
	add_child(active_network)

func create_lobby() -> void:
	_build_multiplayer_network()
	active_network.create_lobby()

func join_lobby(lobby_id: int = 0) -> void:
	_build_multiplayer_network()
	active_network.join_lobby(lobby_id)

func open_lobby_list() -> void:
	_build_multiplayer_network()
	active_network.open_lobby_list()

func connect_peer_to_lobby(peer_id: int) -> void:
	print("Peer ", peer_id, " joined the game!")
	var player_instance: Player = PLAYER.instantiate()
	player_instance.player_id = peer_id
	player_instance.name = str(peer_id)
	player_instance.position = Vector2(400, 400)
	get_node("/root/World").add_child(player_instance)

func disconnect_peer_from_lobby(peer_id: int) -> void:
	var player_to_delete: Node = get_node("/root/World").get_node(str(peer_id))
	if player_to_delete:
		print("Peer ", peer_id, " left the game!")
		player_to_delete.queue_free()
	else:
		print("Couldn't find peer: ", peer_id)
