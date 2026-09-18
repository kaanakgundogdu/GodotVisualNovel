class_name CmdChoiceTimer
extends VNCommand

func command_name() -> String:
	return "choice_timer"

func allows_multiple() -> bool:
	return false

func is_blocking() -> bool:
	return false

func apply(args: String, ctx: CommandContext) -> void:
	var tokens: PackedStringArray = args.strip_edges().split(" ", false)
	if tokens.is_empty() or not tokens[0].is_valid_float():
		VNLog.warn("CmdChoiceTimer", "'@choice_timer' expects a valid number of seconds, got: '%s'" % args)
		return

	var seconds: float = tokens[0].to_float()
	if seconds <= 0.0:
		VNLog.warn("CmdChoiceTimer", "'@choice_timer' seconds must be greater than 0, got: %s" % seconds)
		return

	var default_index: int = 0
	if tokens.size() > 1:
		default_index = tokens[1].to_int()

	ctx.runner.pending_choice_timer = {"seconds": seconds, "default_index": default_index}
