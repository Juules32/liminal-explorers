class_name LobbyContainer
extends CenterContainer

const STEAM_LOBBY_ENTRY: Resource = preload("uid://bpombmlv0o6ts")

@onready var tab_container: TabContainer = $TabContainer
@onready var lobbies_container: VBoxContainer = $TabContainer/Steam/MarginContainer/VBoxContainer/Panel/ScrollContainer/LobbiesContainer
@onready var lobby_name_line_edit: LineEdit = $TabContainer/Steam/MarginContainer/VBoxContainer/HBoxContainer/LobbyNameLineEdit
@onready var steam_running_label: RichTextLabel = $TabContainer/Steam/MarginContainer/VBoxContainer/HBoxContainer/SteamRunningLabel
@onready var connection_string_line_edit: LineEdit = $TabContainer/Iroh/MarginContainer/VBoxContainer/HBoxContainer/ConnectionStringLineEdit
@onready var address_line_edit: LineEdit = $TabContainer/Local/MarginContainer/VBoxContainer/HBoxContainer/AddressLineEdit

func _ready() -> void:
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	if LaunchArgumentParser.auto_host_local:
		_on_e_net_host_button_pressed()
	elif LaunchArgumentParser.auto_join_local:
		_on_e_net_join_button_pressed()


func _on_e_net_host_button_pressed() -> void:
	NetworkManager.create_lobby()
	hide()


func _on_e_net_join_button_pressed() -> void:
	NetworkManager.join_lobby(address_line_edit.text)
	hide()


func _on_steam_host_button_pressed() -> void:
	NetworkManager.create_lobby(lobby_name_line_edit.text)
	hide()


func _on_lobby_match_list(lobby_ids: Variant) -> void:
	for lobby_child: Node in lobbies_container.get_children():
		if lobby_child.get_index() != 0:
			lobby_child.queue_free()
	
	for lobby_id: int in lobby_ids:
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


func _on_tab_container_tab_changed(tab: int) -> void:
	var new_network_type: NetworkManager.NetworkType = tab as NetworkManager.NetworkType
	NetworkManager.active_network_type = new_network_type
	if NetworkManager.active_network_type == NetworkManager.NetworkType.STEAM:
		if steam_running_label:
			steam_running_label.hide()
	NetworkManager.build_multiplayer_network()
	print("Switched to: ", NetworkManager.active_network_type)


func _on_check_steam_running_timer_timeout() -> void:
	var error: Error = NetworkManager.open_lobby_list()
	steam_running_label.visible = error == ERR_CANT_CONNECT


func _on_iroh_host_button_pressed() -> void:
	NetworkManager.create_lobby()
	hide()


func _on_iroh_join_button_pressed() -> void:
	NetworkManager.join_lobby(connection_string_line_edit.text)
	hide()
