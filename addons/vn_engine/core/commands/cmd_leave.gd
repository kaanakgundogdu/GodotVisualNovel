class_name CmdLeave
extends VNCommand

func command_name() -> String:
	return "leave"

func apply(args: String, ctx: CommandContext) -> void:
	CmdHide.new().apply(args, ctx)
