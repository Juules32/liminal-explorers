extends Control

@onready var copy_connection_string_button: Button = $CenterContainer/HBoxContainer/CopyConnectionStringButton


func _process(_delta: float) -> void:
	copy_connection_string_button.visible = multiplayer.multiplayer_peer is IrohServer


func _on_leave_button_pressed() -> void:
	NetworkManager.disconnect_peer_from_lobby(multiplayer.get_unique_id())


func _on_copy_connection_string_button_pressed() -> void:
	if multiplayer.multiplayer_peer is IrohServer:
		DisplayServer.clipboard_set(multiplayer.multiplayer_peer.connection_string())
		print("Copied connection string: " + multiplayer.multiplayer_peer.connection_string())
