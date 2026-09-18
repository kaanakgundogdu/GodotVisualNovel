class_name CmdMusic
extends VNCommand

func command_name() -> String:
	return "music"

func apply(args: String, ctx: CommandContext) -> void:
	var value := args.strip_edges()

	if value.to_lower() == "stop":
		ctx.state.audio.erase("music")
	else:
		ctx.state.audio["music"] = value
		if value != "":
			VNSave.unlock_music(value)

	if ctx.audio:
		ctx.audio.play_channel("music", value)
