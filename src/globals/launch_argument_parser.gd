extends Node

var _window_y_offset: int = 30 if DisplayServer.get_name() == "Windows" else 0
var _primary_screen_id: int = DisplayServer.get_primary_screen()
var _primary_screen_usable_rect: Rect2i = DisplayServer.screen_get_usable_rect(_primary_screen_id)
var _primary_screen_size: Vector2i = _primary_screen_usable_rect.size
var _primary_screen_position: Vector2i = _primary_screen_usable_rect.position + Vector2i(0, _window_y_offset)
var _primary_screen_half_size: Vector2i = Vector2i(_primary_screen_size.x / 2, _primary_screen_size.y - _window_y_offset)

var auto_host_local: bool = false
var auto_join_local: bool = false

func _ready() -> void:
	var args: PackedStringArray = OS.get_cmdline_args()
	if "--position-left" in args:
		_position_window_left()
	if "--position-right" in args:
		_position_window_right()
	if "--host-local" in args:
		auto_host_local = true
		get_window().title = "Server"
	if "--join-local" in args:
		auto_join_local = true
		get_window().title = "Client"


func _position_window_left() -> void:
	DisplayServer.window_set_position(_primary_screen_position)
	DisplayServer.window_set_size(_primary_screen_half_size)


func _position_window_right() -> void:
	DisplayServer.window_set_position(
		_primary_screen_position + Vector2i(_primary_screen_half_size.x, 0)
	)
	DisplayServer.window_set_size(_primary_screen_half_size)
