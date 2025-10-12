class_name PlayerVisionTeleporter
extends VisibleOnScreenNotifier3D

@export var is_in_view: bool = false
var has_been_seen: bool = false 
var has_moved: bool = false

func _on_screen_entered() -> void:
	W.print("Button entered screen")
	has_been_seen = true
	is_in_view = true

func _on_screen_exited() -> void:
	is_in_view = false
	
	W.print("Button exited screen")
	if has_been_seen and not has_moved:
		print(multiplayer.get_unique_id())
		check_noone_looking.rpc()

# Should not be call_local because it will see that its own is_in_view is false which
# is a given
@rpc("any_peer", "call_remote", "reliable")
func check_noone_looking() -> void:
	print("received noone looking request")
	print(multiplayer.get_unique_id())
	
	if not is_in_view:
		Signals.start_player_carriage_teleport.emit()
	else:
		print("not all players not looking")
