@tool
extends EditorScript


func _run() -> void:
	var txt_files: Array[String] = []
	_collect_txt_files(VNPaths.scenario_root(), txt_files)
	txt_files.sort()

	var current_ids: Array[String] = []
	for path in txt_files:
		var story: StoryScript = ScenarioParser.parse_file(path)
		for node in story.nodes:
			if node.line_id != "":
				current_ids.append(node.line_id)
			for choice in node.choices:
				if choice.line_id != "":
					current_ids.append(choice.line_id)

	current_ids.sort()

	var previous_ids: Array[String] = _read_previous_ids(VNPaths.line_ids())
	var current_set: Dictionary = {}
	for id in current_ids:
		current_set[id] = true

	var warning_count := 0
	for old_id in previous_ids:
		if not current_set.has(old_id):
			VNLog.warn("LineIdTool", "'%s' is no longer produced, did a label change?" % old_id)
			warning_count += 1

	_write_ids(VNPaths.line_ids(), current_ids)

	VNLog.info("LineIdTool", "%d file(s) scanned, %d id(s) generated, %d id(s) lost (warning)." % [txt_files.size(), current_ids.size(), warning_count])


func _collect_txt_files(dir_path: String, out: Array[String]) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if entry == "." or entry == "..":
			entry = dir.get_next()
			continue

		var full_path: String = dir_path.path_join(entry)
		if dir.current_is_dir():
			_collect_txt_files(full_path, out)
		elif entry.get_extension().to_lower() == "txt":
			out.append(full_path)

		entry = dir.get_next()
	dir.list_dir_end()


func _read_previous_ids(path: String) -> Array[String]:
	var result: Array[String] = []
	if not FileAccess.file_exists(path):
		return result

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return result

	var text: String = file.get_as_text()
	file.close()

	for raw_line in text.split("\n"):
		var stripped: String = raw_line.strip_edges()
		if stripped != "":
			result.append(stripped)

	return result


func _write_ids(path: String, ids: Array[String]) -> void:
	if not DirAccess.dir_exists_absolute(VNPaths.locale_dir()):
		DirAccess.make_dir_recursive_absolute(VNPaths.locale_dir())

	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		VNLog.error("LineIdTool", "Could not write '%s' (error code %d)" % [path, FileAccess.get_open_error()])
		return

	for id in ids:
		file.store_line(id)
	file.close()
