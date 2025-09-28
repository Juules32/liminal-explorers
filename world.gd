@icon("res://addons/plenticons/icons/16x/objects/globe-yellow.png")

class_name World
extends Node


func _on_button_pressed() -> void:
	NetworkManager.disconnect_peer_from_lobby(multiplayer.get_unique_id())
