extends Node

enum NetworkType { ENET, STEAM, IROH }

const PLAYER: Resource = preload("uid://c4qhceyy2snhx")
const ENET_NETWORK: Resource = preload("uid://d1xy2osd1n2jp")
const STEAM_NETWORK: Resource = preload("uid://cvofp4wy4vl4t")
const IROH_NETWORK: Resource = preload("uid://d3xag4pw71grj")

var active_network_type: NetworkType = NetworkType.ENET
var active_network: AbstractNetwork


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)


func build_multiplayer_network() -> Error:
	match active_network_type:
		NetworkType.ENET:
			print("Setting network type to ENet")
			return _set_active_network(ENET_NETWORK)
		NetworkType.STEAM:
			print("Setting network type to Steam")
			return _set_active_network(STEAM_NETWORK)
		NetworkType.IROH:
			print("Setting network type to Iroh")
			return _set_active_network(IROH_NETWORK)
		_:
			print("No match for network type!")
	return ERR_CANT_CREATE


func create_lobby(lobby_name: String = "") -> Error:
	var error: Error = build_multiplayer_network()
	
	if error == OK:
		active_network.create_lobby(lobby_name)
	
	return error


func join_lobby(lobby_id: Variant = 0) -> Error:
	var error: Error = build_multiplayer_network()
	print(error)
	
	if error == OK:
		var join_error: Error = active_network.join_lobby(lobby_id)
		return join_error
	else:
		return error


func open_lobby_list() -> Error:
	if active_network and Steam.isSteamRunning():
		active_network.open_lobby_list()
		return OK
	
	return ERR_CANT_CONNECT


func connect_peer_to_lobby(peer_id: int) -> void:
	if multiplayer.is_server():
		print("Peer ", peer_id, " joined the game!")
		var unique_id: int = multiplayer.get_remote_sender_id()
		var player_instance: Player = PLAYER.instantiate()
		player_instance.player_id = peer_id
		player_instance.name = str(peer_id)
		get_node("/root/Game/World").add_child(player_instance)


# TODO: Make this work as intended
func disconnect_peer_from_lobby(peer_id: int) -> void:
	var player_to_delete: Node = get_node("/root/Game/World").get_node(str(peer_id))
	if player_to_delete:
		print("Peer ", peer_id, " left the game!")
		player_to_delete.queue_free()
	else:
		print("Couldn't find peer: ", peer_id)
	if peer_id == multiplayer.get_unique_id():
		(func() -> void: multiplayer.multiplayer_peer.close()).call_deferred()
		multiplayer.peer_connected.disconnect(connect_peer_to_lobby)
		multiplayer.peer_disconnected.disconnect(disconnect_peer_from_lobby)


func _set_active_network(network_scene: Resource) -> Error:
	var network_scene_initialized: AbstractNetwork = network_scene.instantiate()
	
	if network_scene_initialized.init_error != OK:
		return network_scene_initialized.init_error
	
	active_network = network_scene_initialized
	
	for child: Node in get_children():
		child.queue_free()
	
	# Necessary for signals
	add_child(active_network)
	
	return OK


func _on_peer_connected(peer_id: int) -> void:
	connect_peer_to_lobby(peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	disconnect_peer_from_lobby(peer_id)


func _on_connected_to_server() -> void:
	print("Client connected to server")


func _on_server_disconnected() -> void:
	print("Client disconnected from server")


func _on_connection_failed() -> void:
	print("Client failed to connect to server")
