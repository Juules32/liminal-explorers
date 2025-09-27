class_name SteamNetwork
extends AbstractNetwork

const LOBBY_NAME = "xxxa"
const LOBBY_MODE: String = "CoOP"
const MAX_MEMBERS: int = 10
const STEAM_APP_ID: int = 480 # Test game app id

var peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()
var hosted_lobby_id: int = 0
var steam_id: int = 0
var steam_username: String = ""

func _ready() -> void:
	print("Init Steam")
	OS.set_environment("SteamAppId", str(STEAM_APP_ID))
	OS.set_environment("SteamGameId", str(STEAM_APP_ID))
	
	var initialize_response: Dictionary = Steam.steamInitEx()
	
	if initialize_response['status'] > 0:
		print("Failed to init Steam! Shutting down. %s" % initialize_response)
		get_tree().quit()
	
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	print("Steam id: ", steam_id)
	print("Steam username: ", steam_username)

	if Steam.isSubscribed() == false:
		print("User does not own game!")
		get_tree().quit()

	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	NetworkManager.open_lobby_list()

func _process(_delta: float) -> void:
	Steam.run_callbacks()

func create_lobby() -> void:
	print("Creating lobby...")
	print(multiplayer)
	multiplayer.peer_connected.connect(NetworkManager.connect_peer_to_lobby)
	multiplayer.peer_disconnected.connect(NetworkManager.disconnect_peer_from_lobby)
	
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, MAX_MEMBERS)

func join_lobby(lobby_id: int) -> void:
	print("Joining lobby ", lobby_id)
	Steam.joinLobby(lobby_id)

func _on_lobby_created(foo: int, lobby_id: int) -> void:
	print("On lobby created")
	if foo == 1:
		print("Created lobby ", lobby_id)
		hosted_lobby_id = lobby_id
		
		Steam.setLobbyJoinable(lobby_id, true)
		
		Steam.setLobbyData(lobby_id, "name", LOBBY_NAME)
		Steam.setLobbyData(lobby_id, "mode", LOBBY_MODE)
		
		var error: Error = peer.create_host(0)
		if error == OK:
			multiplayer.multiplayer_peer = peer
			NetworkManager.connect_peer_to_lobby(1)
		else:
			push_error("Error creating lobby: ", error)

func _on_lobby_joined(lobby: int, _permissions: int, _locked: bool, response: int) -> void:
	print("On lobby joined: ", response)
	
	if response == 1:
		var lobby_owner_id: int = Steam.getLobbyOwner(lobby)
		if lobby_owner_id != Steam.getSteamID():
			print("Connecting client to socket...")
			var error: Error = peer.create_client(lobby_owner_id, 0)
			if error == OK:
				print("Connecting peer to host...")
				multiplayer.multiplayer_peer = peer
			else:
				push_error("Error creating client: ", error)
	else:
		match response:
			2:  print("This lobby no longer exists.")
			3:  print("You don't have permission to join this lobby.")
			4:  print("The lobby is now full.")
			5:  print("Uh... something unexpected happened!")
			6:  print("You are banned from this lobby.")
			7:  print("You cannot join due to having a limited account.")
			8:  print("This lobby is locked or disabled.")
			9:  print("This lobby is community locked.")
			10: print("A user in the lobby has blocked you from joining.")
			11: print("A user you have blocked is in the lobby.")

func open_lobby_list() -> void:
	#if not Steam.isSteamRunning():
	#	return
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()
