extends Node

@onready var world: World = $World
@onready var lobby_container: CenterContainer = $LobbyContainer

func _on_enter_world() -> void:
	world.show()
	lobby_container.hide()

func _on_quit_world() -> void:
	world.hide()
	lobby_container.show()
