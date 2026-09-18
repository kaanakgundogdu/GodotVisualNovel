class_name CmdEnd
extends VNCommand

func command_name() -> String:
	return "end"

func apply(args: String, ctx: CommandContext) -> void:
	var ending_id: String = args.strip_edges()
	ctx.runner.end_story(StoryRunner.EndReason.EXPLICIT_END, ending_id)
	ctx.runner._jumped = true
