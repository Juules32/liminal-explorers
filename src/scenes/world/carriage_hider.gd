extends VisibleOnScreenNotifier3D

@export var carriage: Node3D

var _has_been_seen: bool = false 


func _on_screen_entered() -> void:
	W.print("Carriage entered screen")
	_has_been_seen = true


func _on_screen_exited() -> void:
	W.print("Carriage exited screen")
	if _has_been_seen:
		carriage.hide()
