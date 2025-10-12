@icon("res://addons/plenticons/icons/16x/objects/globe-yellow.png")
class_name World
extends Node

@export var main_carriage: Node3D
@export var second_carriage: Node3D


func _ready() -> void:
	Signals.start_player_carriage_teleport.connect(_on_start_player_carriage_teleport)


func _on_start_player_carriage_teleport() -> void:
	W.print("bong")
	Signals.move_player_carriage_teleport.emit(main_carriage, second_carriage)
