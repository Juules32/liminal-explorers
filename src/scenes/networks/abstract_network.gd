@abstract
class_name AbstractNetwork
extends Node

var init_error: Error = OK

@abstract
func open_lobby_list() -> void

@abstract
func create_lobby(lobby_name: String) -> void

@abstract
func join_lobby(lobby_id: Variant) -> Error
