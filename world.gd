@icon("res://addons/plenticons/icons/16x/objects/globe-yellow.png")

extends Node2D

@onready var lobbies_container: VBoxContainer = $CenterContainer/TabContainer/Steam/MarginContainer/VBoxContainer/Panel/ScrollContainer/LobbiesContainer

func _ready() -> void:
	Steam.lobby_match_list.connect(_on_lobby_match_list)

func _on_steam_host_button_pressed() -> void:
	NetworkManager.create_lobby()

func _on_steam_lobby_button_pressed() -> void:
	NetworkManager.open_lobby_list()

func _on_lobby_match_list(lobby_ids: Variant) -> void:
	for child in lobbies_container.get_children():
		child.free()
	
	for lobby_child: Node in lobbies_container.get_children():
		lobby_child.queue_free()
	
	for lobby_id in (lobby_ids as Array[int]):
		var lobby_name: String = Steam.getLobbyData(lobby_id, "name")
		var member_count: int = Steam.getNumLobbyMembers(lobby_id)
		var button: Button = Button.new()
		button.text = lobby_name + ", Player count: " + str(member_count)
		button.size = Vector2(100, 5)
		button.pressed.connect(func() -> void: NetworkManager.join_lobby(lobby_id))
		lobbies_container.add_child(button)

func _on_e_net_host_button_pressed() -> void:
	NetworkManager.create_lobby()

func _on_e_net_join_button_pressed() -> void:
	NetworkManager.join_lobby()

func _on_tab_container_tab_changed(tab: int) -> void:
	NetworkManager.active_network_type = tab as NetworkManager.MULTIPLAYER_NETWORK_TYPE
	print("Switched to: ", NetworkManager.active_network_type)
