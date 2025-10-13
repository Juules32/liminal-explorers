extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		if (body as Player).authority_node.is_multiplayer_authority():
			Signals.start_third_animation.emit()
			W.print("emitting body entered")
