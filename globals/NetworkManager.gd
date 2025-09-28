extends Node

enum MULTIPLAYER_NETWORK_TYPE { ENET, STEAM }
const PLAYER: Resource = preload("uid://c4qhceyy2snhx")

var active_network_type: MULTIPLAYER_NETWORK_TYPE = MULTIPLAYER_NETWORK_TYPE.ENET
var enet_network_scene: Resource = preload("res://enet_network.tscn")
var steam_network_scene: Resource = preload("res://steam_network.tscn")
var active_network: AbstractNetwork

func _build_multiplayer_network() -> Error:
	match active_network_type:
		MULTIPLAYER_NETWORK_TYPE.ENET:
			print("Setting network type to ENet")
			return _set_active_network(enet_network_scene)
		MULTIPLAYER_NETWORK_TYPE.STEAM:
			print("Setting network type to Steam")
			return _set_active_network(steam_network_scene)
		_:
			print("No match for network type!")
	return ERR_CANT_CREATE

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

func create_lobby(lobby_name: String = "") -> void:
	var error: Error = _build_multiplayer_network()
	
	if error == OK:
		active_network.create_lobby(lobby_name)

func join_lobby(lobby_id: int = 0) -> void:
	var error: Error = _build_multiplayer_network()
	
	if error == OK:
		active_network.join_lobby(lobby_id)

func open_lobby_list() -> void:
	var error: Error = _build_multiplayer_network()
	
	if error == OK:
		active_network.open_lobby_list()

func connect_peer_to_lobby(peer_id: int) -> void:
	print("Peer ", peer_id, " joined the game!")
	var player_instance: Player = PLAYER.instantiate()
	player_instance.player_id = peer_id
	player_instance.name = str(peer_id)
	player_instance.position = Vector2(400, 400)
	get_tree().change_scene_to_file("res://world.tscn")
	await get_tree().scene_changed
	get_node("/root/World").add_child(player_instance)

func disconnect_peer_from_lobby(peer_id: int) -> void:
	var player_to_delete: Node = get_node("/root/World").get_node(str(peer_id))
	if player_to_delete:
		print("Peer ", peer_id, " left the game!")
		player_to_delete.queue_free()
		if peer_id == multiplayer.get_unique_id():
			get_tree().change_scene_to_file("res://lobby_container.tscn")
			await get_tree().scene_changed
	else:
		print("Couldn't find peer: ", peer_id)
