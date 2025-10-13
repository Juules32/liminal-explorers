@icon("res://addons/plenticons/icons/16x/objects/globe-yellow.png")
class_name World
extends Node

@export var main_carriage: Carriage
@export var second_carriage: Carriage

# Controlled player
var controlled_player: Player

# The player not controlled
var other_player: Player

# Player to move (the player with id == 1 on the server)
var server_player: Player


func _ready() -> void:
	Signals.spawned_player.connect(_on_spawned_player)


# Update player references when a new player is instantiated
func _on_spawned_player(player: Player) -> void:
	if player.authority_node.is_multiplayer_authority():
		controlled_player = player
	if len(multiplayer.get_peers()) and player.id == multiplayer.get_peers().get(0):
		other_player = player
	if multiplayer.is_server() and player.id == 1:
		server_player = player
