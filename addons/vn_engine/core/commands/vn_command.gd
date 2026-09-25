class_name VNCommand
extends RefCounted

func command_name() -> String:
	return ""

func allows_multiple() -> bool:
	return false

func apply(_args: String, _ctx: CommandContext) -> void:
	pass

func is_blocking() -> bool:
	return false

static func parse_quoted_args(args: String) -> Array[String]:
	var result: Array[String] = []
	var text := args.strip_edges()
	var i := 0
	var length := text.length()
	while i < length:
		while i < length and text[i] == " ":
			i += 1
		if i >= length:
			break
		if text[i] == "\"":
			i += 1
			var start := i
			while i < length and text[i] != "\"":
				i += 1
			result.append(text.substr(start, i - start))
			if i < length:
				i += 1
		else:
			var start := i
			while i < length and text[i] != " ":
				i += 1
			result.append(text.substr(start, i - start))
	return result
