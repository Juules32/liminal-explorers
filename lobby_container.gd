class_name LobbyContainer
extends CenterContainer

@onready var lobbies_container: VBoxContainer = $TabContainer/Steam/MarginContainer/VBoxContainer/Panel/ScrollContainer/LobbiesContainer
@onready var lobby_name_line_edit: LineEdit = $TabContainer/Steam/MarginContainer/VBoxContainer/HBoxContainer/LobbyNameLineEdit
@onready var steam_running_label: RichTextLabel = $TabContainer/Steam/MarginContainer/VBoxContainer/HBoxContainer/SteamRunningLabel

const STEAM_LOBBY_ENTRY = preload("uid://bpombmlv0o6ts")

func _ready() -> void:
	Steam.lobby_match_list.connect(_on_lobby_match_list)

func _on_steam_host_button_pressed() -> void:
	NetworkManager.create_lobby(lobby_name_line_edit.text)
	hide()

func _on_lobby_match_list(lobby_ids: Variant) -> void:
	for lobby_child: Node in lobbies_container.get_children():
		if lobby_child.get_index() != 0:
			lobby_child.queue_free()
	
	for lobby_id in (lobby_ids as Array[int]):
		var lobby_name: String = Steam.getLobbyData(lobby_id, "name")
		var lobby_owner: String = Steam.getLobbyData(lobby_id, "owner")
		var player_count: int = Steam.getNumLobbyMembers(lobby_id)
		var steam_lobby_entry: SteamLobbyEntry = STEAM_LOBBY_ENTRY.instantiate()
		steam_lobby_entry.ready.connect(func() -> void:
			steam_lobby_entry.join_button.pressed.connect(func() -> void:
				NetworkManager.join_lobby(lobby_id)
				hide()
			)
			steam_lobby_entry.name_label.text = lobby_name
			steam_lobby_entry.owner_label.text = lobby_owner
			steam_lobby_entry.player_count_label.text = str(player_count)
		)
		lobbies_container.add_child(steam_lobby_entry)

func _on_e_net_host_button_pressed() -> void:
	NetworkManager.create_lobby()
	hide()

func _on_e_net_join_button_pressed() -> void:
	NetworkManager.join_lobby()
	hide()

func _on_tab_container_tab_changed(tab: int) -> void:
	var new_network_type: NetworkManager.MULTIPLAYER_NETWORK_TYPE = tab as NetworkManager.MULTIPLAYER_NETWORK_TYPE
	NetworkManager.active_network_type = new_network_type
	NetworkManager.build_multiplayer_network()
	_on_check_steam_running_timer_timeout()
	print("Switched to: ", NetworkManager.active_network_type)

func _on_check_steam_running_timer_timeout() -> void:
	var error: Error = NetworkManager.open_lobby_list()
	steam_running_label.visible = error == ERR_CANT_CONNECT
