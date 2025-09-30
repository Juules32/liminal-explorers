class_name IrohNetwork
extends AbstractNetwork

func create_lobby(_lobby_name: String) -> void:
	var peer: IrohServer = IrohServer.start()
	multiplayer.multiplayer_peer = peer
	NetworkManager.connect_peer_to_lobby(1)

func join_lobby(lobby_id: Variant) -> Error:
	var peer: IrohClient = IrohClient.connect(lobby_id)
	multiplayer.multiplayer_peer = peer
	return OK

func open_lobby_list() -> void:
	pass
