extends StaticBody3D


func interact() -> void:
	W.print("Clicked button")
	_emit_start_first_animation()


@rpc("any_peer", "call_local", "reliable")
func _emit_start_first_animation() -> void:
	Signals.start_first_animation.emit()
