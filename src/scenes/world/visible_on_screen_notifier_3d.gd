extends VisibleOnScreenNotifier3D

var has_been_seen: bool = false 
var has_moved: bool = false


func _on_screen_entered() -> void:
	W.print("Button entered screen")
	has_been_seen = true


func _on_screen_exited() -> void:
	W.print("Button exited screen")
	if has_been_seen and not has_moved:
		Signals.move.emit(Vector3(0.0, 0.0, 50.0))
		has_moved = true
