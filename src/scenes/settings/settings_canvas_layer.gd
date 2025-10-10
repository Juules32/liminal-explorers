extends CanvasLayer

const TWEEN_DURATION: float = 0.7

var target_visible: bool = false
var is_tweening: bool = false

@onready var canvas_group: CanvasGroup = $CanvasGroup
@onready var shader_material: ShaderMaterial = canvas_group.material as ShaderMaterial


func _ready() -> void:
	visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("settings"):
		if not is_tweening:
			visible = true
			is_tweening = true
			target_visible = not target_visible
			_update_mouse_mode()
			_animate()


func _update_mouse_mode() -> void:
	if target_visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _tween_progress(to_value: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(shader_material, "shader_parameter/progress", to_value, TWEEN_DURATION)
	tween.finished.connect(func() -> void:
		is_tweening = false
		visible = to_value
	)


func _animate() -> void:
	if target_visible:
		shader_material.set_shader_parameter("progress", 0.0)
		_tween_progress(1.0)
	else:
		_tween_progress(0.0)
