class_name CmdShake
extends VNCommand

func command_name() -> String:
	return "shake"

func apply(args: String, ctx: CommandContext) -> void:
	if ctx.camera:
		ctx.camera.shake(args.strip_edges())
