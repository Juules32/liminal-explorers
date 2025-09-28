class_name ENetNetwork
extends AbstractNetwork

const SERVER_IP = "localhost"
const SERVER_PORT = 8080

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func create_lobby(_lobby_name: String) -> void:
	peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = peer
	
	NetworkManager.connect_peer_to_lobby(1)

func join_lobby(_lobby_id: int) -> void:
	print("Player 2 joining")
	
	peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = peer

func open_lobby_list() -> void:
	pass
