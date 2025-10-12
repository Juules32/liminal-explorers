extends Node

func print(message: Variant = "", ...args: Array) -> void:
	var prefix: String = "[" + get_window().title + "]: "
	var text: String = prefix + str(message) + "".join(args.map(str))
	print(text)
