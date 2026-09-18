class_name CmdVoice
extends VNCommand

func command_name() -> String:
	return "voice"

func apply(args: String, ctx: CommandContext) -> void:
	var value := args.strip_edges()

	if value.to_lower() == "stop":
		ctx.state.audio.erase("voice")
	else:
		ctx.state.audio["voice"] = value

	if ctx.audio:
		ctx.audio.play_channel("voice", value)
