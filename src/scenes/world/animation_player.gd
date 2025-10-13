extends AnimationPlayer


@export var world: World


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.start_first_animation.connect(_on_start_first_animation)
	Signals.start_second_animation.connect(_on_start_second_animation)
	Signals.start_third_animation.connect(_on_start_third_animation)


func _on_start_first_animation() -> void:
	play(&"first")


func _on_start_second_animation() -> void:
	play(&"second")


func _on_start_third_animation() -> void:
	play(&"third")


func enable_carriage_teleport() -> void:
	_emit_enable_carriage_teleport.rpc()


@rpc("any_peer", "call_local", "reliable")
func _emit_enable_carriage_teleport() -> void:
	Signals.enable_carriage_teleport.emit()


func enable_hide_carriage() -> void:
	world.main_carriage.carriage_hider.show()
	world.second_carriage.carriage_hider.show()
