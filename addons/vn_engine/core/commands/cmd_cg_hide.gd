class_name CmdCgHide
extends VNCommand

func command_name() -> String:
	return "cg_hide"

func apply(args: String, ctx: CommandContext) -> void:
	var tokens := args.strip_edges().split(" ", false)
	var transition := "fade"

	var i := 0
	while i < tokens.size():
		if tokens[i] == "with" and i + 1 < tokens.size():
			transition = tokens[i + 1]
			i += 2
		else:
			i += 1

	if ctx.state.bg == "":
		VNLog.warn("CmdCgHide", "No background to return to: '@bg' was never called")
		return

	if ctx.background:
		ctx.background.change_to(ctx.state.bg, transition)
