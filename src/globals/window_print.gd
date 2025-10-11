extends Node

func print(...args: Array) -> void:
	var prefix: String = "[" + get_window().title + "]: "
	var text: String = prefix + "".join(args.map(str))
	print(text)
