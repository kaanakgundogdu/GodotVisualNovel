class_name CmdJump
extends VNCommand

func command_name() -> String:
	return "jump"

func apply(args: String, ctx: CommandContext) -> void:
	var target := args.strip_edges()
	var idx := ctx.script_res.index_of(target)

	if idx == -1:
		VNLog.warn("CmdJump", "Target not found: %s" % target)
		return

	ctx.runner.play_node(idx)
	ctx.runner._jumped = true
