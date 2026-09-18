class_name CmdBgmStop
extends VNCommand

func command_name() -> String:
	return "bgm_stop"

func apply(_args: String, ctx: CommandContext) -> void:
	ctx.state.audio.erase("music")
	if ctx.audio:
		ctx.audio.play_channel("music", "stop")
