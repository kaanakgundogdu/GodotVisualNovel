class_name CmdCredits
extends VNCommand

func command_name() -> String:
	return "credits"

func apply(args: String, ctx: CommandContext) -> void:
	VNGame.play_credits(args.strip_edges())
	ctx.runner._jumped = true
