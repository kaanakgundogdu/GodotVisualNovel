@tool
extends EditorScript


const OLD_PREFIX := "#OLD#"


func _run() -> void:
	var txt_files: Array[String] = []
	_collect_txt_files(VNEnginePaths.scenario_root(), txt_files)
	txt_files.sort()

	var generated: Dictionary = {}

	for path in txt_files:
		var story: VNEngineStoryScript = VNEngineScenarioParser.parse_file(path)
		for node in story.nodes:
			if node.line_id != "" and String(node.text).strip_edges() != "":
				generated[node.line_id] = node.text
			for choice in node.choices:
				if choice.line_id != "" and String(choice.text).strip_edges() != "":
					generated[choice.line_id] = choice.text

	var cast: VNEngineCast = load(VNEnginePaths.cast_file()) as VNEngineCast
	if cast != null:
		for entry in cast.characters:
			if entry == null:
				continue
			if entry.is_narrator:
				continue
			var key := "char.%s.name" % entry.id
			generated[key] = entry.display_name

	var existing_rows: Dictionary = _read_existing_csv(VNEnginePaths.dialog_csv())
	var existing_header: PackedStringArray = _read_existing_header(VNEnginePaths.dialog_csv())

	var kept_count := 0
	var new_count := 0
	var old_marked_count := 0

	var out_rows: Array[PackedStringArray] = []

	var generated_keys: Array = generated.keys()
	generated_keys.sort()
	for key in generated_keys:
		if existing_rows.has(key):
			out_rows.append(existing_rows[key])
			kept_count += 1
		else:
			var row := PackedStringArray([key, String(generated[key])])
			out_rows.append(row)
			new_count += 1

	var existing_keys: Array = existing_rows.keys()
	existing_keys.sort()
	for key in existing_keys:
		if generated.has(key):
			continue
		var row: PackedStringArray = existing_rows[key]
		if not String(row[0]).begins_with(OLD_PREFIX):
			row = row.duplicate()
			row[0] = OLD_PREFIX + String(row[0])
			old_marked_count += 1
		out_rows.append(row)

	_write_csv(VNEnginePaths.dialog_csv(), out_rows, existing_header)

	VNEngineLog.info("LocaleCsvTool", "%d file(s) scanned, %d key(s) kept, %d new key(s), %d key(s) marked #OLD#." % [txt_files.size(), kept_count, new_count, old_marked_count])

	var fs: EditorFileSystem = EditorInterface.get_resource_filesystem()
	if fs:
		fs.scan()


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


func _read_existing_csv(path: String) -> Dictionary:
	var result: Dictionary = {}
	if not FileAccess.file_exists(path):
		return result

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return result

	var header := true
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() == 0 or (row.size() == 1 and row[0] == ""):
			continue
		if header:
			header = false
			continue

		var key: String = row[0]
		if key == "":
			continue
		result[key] = row

	file.close()
	return result


func _read_existing_header(path: String) -> PackedStringArray:
	var fallback := PackedStringArray(["keys", "tr"])
	if not FileAccess.file_exists(path):
		return fallback

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return fallback

	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() == 0 or (row.size() == 1 and row[0] == ""):
			continue
		file.close()
		return row

	file.close()
	return fallback


func _write_csv(path: String, rows: Array[PackedStringArray], header: PackedStringArray) -> void:
	if not DirAccess.dir_exists_absolute(VNEnginePaths.locale_dir()):
		DirAccess.make_dir_recursive_absolute(VNEnginePaths.locale_dir())

	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		VNEngineLog.error("LocaleCsvTool", "Could not write '%s' (error code %d)" % [path, FileAccess.get_open_error()])
		return

	file.store_csv_line(header)
	for row in rows:
		file.store_csv_line(row)
	file.close()
