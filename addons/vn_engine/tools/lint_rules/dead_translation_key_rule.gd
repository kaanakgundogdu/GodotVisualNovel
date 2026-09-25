@tool
class_name VNEngineDeadTranslationKeyRule
extends VNEngineAssetLintRule


func title() -> String:
	return "7. Dead translation keys"


func run(ctx: VNEngineAssetLintContext) -> void:
	if not FileAccess.file_exists(VNEnginePaths.dialog_csv()):
		ctx.info("dialog.csv has not been generated yet (run locale_csv_tool) -- expected, 0 findings")
		return

	if not FileAccess.file_exists(VNEnginePaths.line_ids()):
		ctx.info("line_ids.txt has not been generated yet (run line_id_tool), cannot compare -- expected, 0 findings")
		return

	var current_ids: Dictionary = {}
	var line_ids_file: FileAccess = FileAccess.open(VNEnginePaths.line_ids(), FileAccess.READ)
	if line_ids_file:
		while not line_ids_file.eof_reached():
			var line: String = line_ids_file.get_line().strip_edges()
			if line != "":
				current_ids[line] = true
		line_ids_file.close()

	var csv_file: FileAccess = FileAccess.open(VNEnginePaths.dialog_csv(), FileAccess.READ)
	if csv_file:
		var header := true
		while not csv_file.eof_reached():
			var row: PackedStringArray = csv_file.get_csv_line()
			if row.size() == 0 or (row.size() == 1 and row[0] == ""):
				continue
			if header:
				header = false
				continue

			var key: String = row[0].strip_edges()
			if key == "" or key.begins_with("#OLD#"):
				continue
			if not current_ids.has(key):
				ctx.warn("`%s` is in dialog.csv but no node produces it anymore" % key)
		csv_file.close()
