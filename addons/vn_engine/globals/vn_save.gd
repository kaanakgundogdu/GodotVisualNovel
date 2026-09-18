extends Node

enum SlotStatus { EMPTY, OK, CORRUPT, UNSUPPORTED }

const QUICKSAVE_SLOT := 99
const AUTOSAVE_SLOT := 98
const SAVE_FILE_VERSION := 3
const GLOBAL_DATA_VERSION := 3

var slot_to_load: int = -1

var global_data: Dictionary = {
	"version": GLOBAL_DATA_VERSION,
	"seen_lines": {},
	"unlocked_cgs": {},
	"endings_seen": {},
	"movies_seen": {},
	"bgm_heard": {},
	"flags": {},
	"total_playtime_sec": 0,
	"cleared_count": 0,
	"first_clear_at": 0,
}

var _global_dirty: bool = false

var _save_namespace: String = ""


func _ready() -> void:
	_save_namespace = _resolve_save_namespace()
	DirAccess.make_dir_recursive_absolute(get_save_dir())
	_load_global_data()
	var flush_timer: Timer = Timer.new()
	flush_timer.wait_time = 5.0
	flush_timer.autostart = true
	flush_timer.timeout.connect(_flush_global_data)
	add_child(flush_timer)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		_flush_global_data()


func _resolve_save_namespace() -> String:
	var manifest_path: String = VNPaths.manifest()
	var ns: String = ""
	if ResourceLoader.exists(manifest_path):
		var manifest: GameManifest = ResourceLoader.load(manifest_path) as GameManifest
		if manifest != null:
			ns = manifest.game_id.strip_edges()
	if ns == "":
		var root: String = VNPaths.content_root().trim_suffix("/")
		ns = root.get_file()
	ns = ns.validate_filename()
	if ns == "":
		ns = "default"
	return ns


func get_save_dir() -> String:
	return "user://saves/" + _save_namespace + "/"


func mark_line_seen(chapter_id: String, line_id: String) -> void:
	if not global_data["seen_lines"].has(chapter_id):
		global_data["seen_lines"][chapter_id] = {}

	var seen: Dictionary = global_data["seen_lines"][chapter_id]
	if not seen.has(line_id):
		seen[line_id] = true
		_global_dirty = true


func is_line_seen(chapter_id: String, line_id: String) -> bool:
	if global_data["seen_lines"].has(chapter_id):
		var seen: Dictionary = global_data["seen_lines"][chapter_id]
		return seen.has(line_id)
	return false


func save_game(state: StoryState, slot_id: int) -> void:
	_flush_global_data()
	var save_path: String = _slot_path(slot_id)
	var image: Image = get_viewport().get_texture().get_image()

	if image != null:
		image.resize(256, 144)
		image.save_png(_slot_thumbnail_path(slot_id))

	var preview_text: String = ""
	if not state.history.is_empty():
		var last_entry: Dictionary = state.history[state.history.size() - 1]
		var full_text: String = str(last_entry.get("text", ""))
		preview_text = full_text.substr(0, 60)

	var locale: String = VNLocale.get_language()

	var meta: Dictionary = {
		"chapter_id": state.chapter_id,
		"chapter_title_key": "",
		"preview_text": preview_text,
		"speaker": state.last_speaker,
		"playtime_sec": state.playtime_sec,
		"locale": locale,
		"ending_id": "",
	}

	var data: Dictionary = {
		"version": SAVE_FILE_VERSION,
		"engine": "vn_engine/0.3",
		"saved_at": int(Time.get_unix_time_from_system()),
		"meta": meta,
		"state": state.to_dict(),
	}

	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()


func load_game(slot_id: int) -> Variant:
	var status: SlotStatus = get_slot_status(slot_id)
	var save_path: String = _slot_path(slot_id)

	match status:
		SlotStatus.EMPTY:
			VNLog.warn("VNSave", "Save slot is empty: %d" % slot_id)
			return null
		SlotStatus.CORRUPT:
			VNLog.warn("VNSave", "Save file could not be parsed: %s" % save_path)
			return null
		SlotStatus.UNSUPPORTED:
			VNLog.warn("VNSave", "Save file version is newer than supported: %s" % save_path)
			return null

	var raw: Variant = _read_json_dict(save_path)
	return _migrate(raw)


func get_slot_status(slot_id: int) -> SlotStatus:
	var save_path: String = _slot_path(slot_id)
	if not FileAccess.file_exists(save_path):
		return SlotStatus.EMPTY

	var raw: Variant = _read_json_dict(save_path)
	if raw == null:
		return SlotStatus.CORRUPT

	var raw_dict: Dictionary = raw
	if not raw_dict.has("version"):
		return SlotStatus.OK

	var version: int = int(raw_dict.get("version", 1))
	if version > SAVE_FILE_VERSION:
		return SlotStatus.UNSUPPORTED

	var state_data: Dictionary = raw_dict.get("state", {})
	if state_data.is_empty():
		return SlotStatus.CORRUPT

	return SlotStatus.OK


func is_slot_used(slot_id: int) -> bool:
	return FileAccess.file_exists(_slot_path(slot_id))


func get_save_thumbnail(slot_id: int) -> Texture2D:
	var img_path: String = _slot_thumbnail_path(slot_id)
	if FileAccess.file_exists(img_path):
		var image: Image = Image.load_from_file(img_path)
		if image != null:
			return ImageTexture.create_from_image(image)
	return null


func unlock_cg(cg_name: String) -> void:
	if not global_data.has("unlocked_cgs"):
		global_data["unlocked_cgs"] = {}

	if not global_data["unlocked_cgs"].has(cg_name):
		global_data["unlocked_cgs"][cg_name] = true
		_save_global_data()


func set_global_flag(id: String, value: Variant) -> void:
	global_data["flags"][id.to_lower()] = value
	_global_dirty = true


func get_global_flag(id: String, default_value: Variant = null) -> Variant:
	return global_data["flags"].get(id.to_lower(), default_value)


func mark_ending_seen(id: String) -> void:
	var key: String = id.to_lower()
	if not global_data["endings_seen"].has(key):
		global_data["endings_seen"][key] = int(Time.get_unix_time_from_system())
		_global_dirty = true


func unlock_music(id: String) -> void:
	var key: String = id.to_lower()
	if not global_data["bgm_heard"].has(key):
		global_data["bgm_heard"][key] = int(Time.get_unix_time_from_system())
		_global_dirty = true


func unlock_movie(id: String) -> void:
	var key: String = id.to_lower()
	if not global_data["movies_seen"].has(key):
		global_data["movies_seen"][key] = int(Time.get_unix_time_from_system())
		_global_dirty = true


func is_music_unlocked(id: String) -> bool:
	return global_data["bgm_heard"].has(id.to_lower())


func is_movie_unlocked(id: String) -> bool:
	return global_data["movies_seen"].has(id.to_lower())


func is_ending_seen(id: String) -> bool:
	return global_data["endings_seen"].has(id.to_lower())


func increment_cleared_count() -> void:
	global_data["cleared_count"] = int(global_data.get("cleared_count", 0)) + 1
	_global_dirty = true


func _slot_path(slot_id: int) -> String:
	return get_save_dir() + "save_slot_" + str(slot_id) + ".json"


func _slot_thumbnail_path(slot_id: int) -> String:
	return get_save_dir() + "save_slot_" + str(slot_id) + ".png"


func _read_json_dict(path: String) -> Variant:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	if json.parse(text) != OK:
		return null

	var data: Variant = json.get_data()
	if not (data is Dictionary):
		return null
	return data


func _global_data_path() -> String:
	return get_save_dir() + "global_data.json"


func _flush_global_data() -> void:
	if _global_dirty:
		_save_global_data()
		_global_dirty = false


func _save_global_data() -> void:
	var file: FileAccess = FileAccess.open(_global_data_path(), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(global_data, "\t"))
		file.close()


func _load_global_data() -> void:
	var path: String = _global_data_path()
	if not FileAccess.file_exists(path):
		return

	var raw: Variant = _read_json_dict(path)
	if raw == null:
		var corrupt_path: String = get_save_dir() + "global_data.corrupt-%d.json.bak" % int(Time.get_unix_time_from_system())
		var dir: DirAccess = DirAccess.open("user://")
		if dir != null:
			dir.rename(path, corrupt_path)
		VNLog.error("VNSave", "global_data.json could not be parsed, renamed to '%s', continuing with defaults" % corrupt_path)
		return

	global_data = _migrate_global(raw)


func _migrate_global_v1_to_v2(raw: Dictionary) -> Dictionary:
	var raw_seen: Dictionary = raw.get("seen_nodes", {})
	var new_seen: Dictionary = {}
	for file_path in raw_seen.keys():
		var value: Variant = raw_seen[file_path]
		if value is Array:
			var converted: Dictionary = {}
			for node_id in value:
				converted[str(node_id)] = true
			new_seen[file_path] = converted
		elif value is Dictionary:
			new_seen[file_path] = value

	return {
		"version": 2,
		"seen_nodes": new_seen,
		"unlocked_cgs": raw.get("unlocked_cgs", []),
	}


func _migrate_global_v2_to_v3(raw: Dictionary) -> Dictionary:
	return {
		"version": GLOBAL_DATA_VERSION,
		"seen_lines": {},
		"unlocked_cgs": {},
		"endings_seen": {},
		"movies_seen": {},
		"bgm_heard": {},
		"flags": {},
		"total_playtime_sec": 0,
		"cleared_count": 0,
		"first_clear_at": 0,
	}


func _migrate_global(raw: Dictionary) -> Dictionary:
	var version: int = int(raw.get("version", 1))
	if version >= GLOBAL_DATA_VERSION:
		for key in global_data.keys():
			if not raw.has(key):
				raw[key] = global_data[key]
		return raw

	var migrated: Dictionary = raw
	if version < 2:
		migrated = _migrate_global_v1_to_v2(migrated)
	migrated = _migrate_global_v2_to_v3(migrated)

	var file: FileAccess = FileAccess.open(_global_data_path(), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(migrated, "\t"))
		file.close()

	return migrated


func _migrate(raw: Dictionary) -> Variant:
	if not raw.has("version"):
		return _migrate_v1(raw)

	var version: int = int(raw.get("version", 1))
	if version > SAVE_FILE_VERSION:
		VNLog.warn("VNSave", "Unsupported save version: %d" % version)
		return null

	var state_data: Dictionary = raw.get("state", {})
	if state_data.is_empty():
		VNLog.warn("VNSave", "Save file has no 'state' block: version %d" % version)
		return null
	return state_data


func _migrate_v1(raw: Dictionary) -> Dictionary:
	var characters: Dictionary = {}
	var raw_characters: Dictionary = raw.get("saved_characters", {})
	for id in raw_characters.keys():
		var value: Variant = raw_characters[id]
		if typeof(value) == TYPE_STRING:
			characters[id] = {"expression": value, "position": "center"}
		else:
			characters[id] = value

	return {
		"current_file": raw.get("current_story_file", _fallback_story_file()),
		"current_node_id": str(int(raw.get("current_id", 0))),
		"flags": raw.get("flags", {}),
		"bg": raw.get("saved_bg", ""),
		"audio": raw.get("saved_audio", {}),
		"characters": characters,
		"last_speaker": "",
		"seen_choices": {},
		"call_stack": [],
		"history": [],
	}


func _fallback_story_file() -> String:
	var manifest: GameManifest = VNGame.manifest
	if manifest == null:
		return ""
	var chapter: ChapterDef = manifest.find_chapter(manifest.first_chapter)
	if chapter == null:
		return ""
	return chapter.script_path
