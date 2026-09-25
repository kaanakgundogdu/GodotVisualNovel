class_name VNEngineCmdJumpIf
extends VNEngineCommand

func command_name() -> String:
	return "jump_if"

func apply(args: String, ctx: VNEngineCommandContext) -> void:
	var condition: String = ""
	var target: String = ""

	if args.contains("->"):
		var arrow_parts: PackedStringArray = args.split("->", true, 1)
		condition = arrow_parts[0].strip_edges()
		target = (arrow_parts[1].strip_edges() if arrow_parts.size() > 1 else "")
	else:
		var tokens: PackedStringArray = args.split(" ", false)
		if tokens.size() < 4:
			VNEngineLog.warn("CmdJumpIf", "Invalid jump_if format: %s" % args)
			return
		target = tokens[tokens.size() - 1]
		condition = " ".join(tokens.slice(0, tokens.size() - 1))

	if condition == "" or target == "":
		VNEngineLog.warn("CmdJumpIf", "Invalid jump_if format: %s" % args)
		return

	if not VNEngineExpressionEvaluator.evaluate(condition, ctx.state.flags):
		return

	var idx: int = ctx.script_res.index_of(target)
	if idx == -1:
		VNEngineLog.warn("CmdJumpIf", "Target not found: %s" % target)
		return

	ctx.runner.play_node(idx)
	ctx.runner._jumped = true
