class_name CmdGotoChapter
extends VNCommand

func command_name() -> String:
	return "goto_chapter"

func apply(args: String, ctx: CommandContext) -> void:
	var chapter_id: String = args.strip_edges()
	if chapter_id == "":
		VNLog.warn("CmdGotoChapter", "'@goto_chapter' expects a chapter id")
		ctx.runner._jumped = true
		return

	VNGame.goto_chapter(chapter_id)
	ctx.runner._jumped = true
