class_name CmdDatecard
extends VNCommand

func command_name() -> String:
	return "datecard"

func is_blocking() -> bool:
	return true

func apply(args: String, ctx: CommandContext) -> void:
	var tokens: Array[String] = _parse_quoted_args(args)
	if tokens.is_empty():
		VNLog.warn("CmdDatecard", "Missing argument: '@datecard' expects at least 1 line of text")
		if ctx.bus:
			ctx.bus.resolve_block()
		return

	var line1: String = tokens[0]
	var line2: String = tokens[1] if tokens.size() > 1 else ""
	var line3: String = tokens[2] if tokens.size() > 2 else ""

	var vn_main: VNMain = VNMain.instance()
	var overlay: CardOverlay = vn_main.get_card_overlay() if vn_main != null else null
	if overlay == null:
		VNLog.warn("CmdDatecard", "CardOverlay not found, resolving block immediately")
		if ctx.bus:
			ctx.bus.resolve_block()
		return

	overlay.open(CardOverlay.MODE_DATECARD, {"line1": line1, "line2": line2, "line3": line3})
	await overlay.finished

	if ctx.bus:
		ctx.bus.resolve_block()


func _parse_quoted_args(args: String) -> Array[String]:
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
