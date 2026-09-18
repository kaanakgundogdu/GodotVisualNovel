@tool
class_name UnmatchedVoiceRule
extends AssetLintRule


func title() -> String:
	return "6. Unidentified voice lines"


func run(ctx: AssetLintContext) -> void:
	if not FileAccess.file_exists(VNPaths.line_ids()):
		ctx.info("line_ids.txt has not been generated yet (run line_id_tool) -- expected, 0 findings")
		return

	var line_ids: Dictionary = {}
	var line_ids_file: FileAccess = FileAccess.open(VNPaths.line_ids(), FileAccess.READ)
	if line_ids_file:
		while not line_ids_file.eof_reached():
			var line: String = line_ids_file.get_line().strip_edges()
			if line != "":
				line_ids[line] = true
		line_ids_file.close()

	var voices_root: String = ""
	if ctx.asset_map != null:
		for entry: AssetMapEntry in ctx.asset_map.entries:
			if entry != null and entry.kind == "voice":
				voices_root = entry.root
	if voices_root == "":
		return
	for file in ctx.walk_files(voices_root):
		var basename: String = file["basename"]
		if not basename.ends_with(".ogg"):
			continue
		var line_id: String = basename.substr(0, basename.length() - 4)
		if not line_ids.has(line_id):
			ctx.warn("`%s%s` -- '%s' matches no line id" % [voices_root, file["rel_path"], line_id])
