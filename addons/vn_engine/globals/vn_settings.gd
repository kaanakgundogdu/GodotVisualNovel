extends Node

signal settings_changed

const TEXT_SPEED_MIN := 0.005
const TEXT_SPEED_MAX := 0.10

const AUTO_SPEED_MIN := 0.5
const AUTO_SPEED_MAX := 5.0

const WINDOW_SIZES: Array[Vector2i] = [
	Vector2i(960, 540),
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
]
const FALLBACK_WINDOW_SIZE := Vector2i(1280, 720)

var data: Dictionary = {}

var _muted_by_focus_loss: bool = false


func _init() -> void:
	data = default_data()


func _ready() -> void:
	_load_settings()
	apply_all_settings()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			if bool(data["audio"]["mute_on_focus_loss"]):
				_muted_by_focus_loss = true
				_apply_audio()
		NOTIFICATION_APPLICATION_FOCUS_IN:
			if _muted_by_focus_loss:
				_muted_by_focus_loss = false
				_apply_audio()


static func default_data() -> Dictionary:
	return {
		"display": {
			"fullscreen": false,
			"window_size": "",
			"vsync": true,
		},
		"audio": {
			"master": 1.0,
			"music": 1.0,
			"sfx": 1.0,
			"voice": 1.0,
			"voice_volume": {},
			"mute_on_focus_loss": false,
		},
		"text": {
			"speed": 0.05,
			"auto_speed": 2.0,
			"skip_unread": false,
			"window_opacity": 0.85,
			"language": "",
		},
		"autosave": true,
	}


func save_settings() -> void:
	var file: FileAccess = FileAccess.open(VNPaths.settings_file(), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()


func reset_to_defaults() -> void:
	data = default_data()
	apply_all_settings()
	save_settings()


func apply_all_settings() -> void:
	_apply_display()
	_apply_audio()
	_apply_language()
	settings_changed.emit()


func get_window_size() -> Vector2i:
	var parsed: Vector2i = _parse_size(String(data["display"]["window_size"]))
	if parsed != Vector2i.ZERO:
		return parsed
	var window_width: int = int(ProjectSettings.get_setting("display/window/size/window_width_override", 0))
	var window_height: int = int(ProjectSettings.get_setting("display/window/size/window_height_override", 0))
	if window_width > 0 and window_height > 0:
		return Vector2i(window_width, window_height)
	return FALLBACK_WINDOW_SIZE


func set_window_size(size: Vector2i) -> void:
	data["display"]["window_size"] = "%dx%d" % [size.x, size.y]


func set_text_speed_normalized(t: float) -> void:
	t = clampf(t, 0.0, 1.0)
	data["text"]["speed"] = lerpf(TEXT_SPEED_MAX, TEXT_SPEED_MIN, t)


func get_text_speed_normalized() -> float:
	var speed: float = clampf(data["text"]["speed"], TEXT_SPEED_MIN, TEXT_SPEED_MAX)
	return inverse_lerp(TEXT_SPEED_MAX, TEXT_SPEED_MIN, speed)


func set_auto_speed_normalized(t: float) -> void:
	t = clampf(t, 0.0, 1.0)
	data["text"]["auto_speed"] = lerpf(AUTO_SPEED_MAX, AUTO_SPEED_MIN, t)


func get_auto_speed_normalized() -> float:
	var auto_speed: float = clampf(data["text"]["auto_speed"], AUTO_SPEED_MIN, AUTO_SPEED_MAX)
	return inverse_lerp(AUTO_SPEED_MAX, AUTO_SPEED_MIN, auto_speed)


func _apply_display() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var window: Window = get_window()
	if bool(data["display"]["fullscreen"]):
		window.mode = Window.MODE_FULLSCREEN
	else:
		var target: Vector2i = get_window_size()
		var was_windowed: bool = window.mode == Window.MODE_WINDOWED
		window.mode = Window.MODE_WINDOWED
		if not was_windowed or window.size != target:
			window.size = target
			var screen_rect: Rect2i = DisplayServer.screen_get_usable_rect(window.current_screen)
			window.position = screen_rect.position + (screen_rect.size - target) / 2

	var vsync_mode: DisplayServer.VSyncMode = DisplayServer.VSYNC_ENABLED if bool(data["display"]["vsync"]) else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(vsync_mode)


func _apply_audio() -> void:
	var master_bus: int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(data["audio"]["master"]))
	AudioServer.set_bus_mute(master_bus, _muted_by_focus_loss)

	for bus_key: String in ["music", "sfx", "voice"]:
		var idx: int = AudioServer.get_bus_index(bus_key.capitalize())
		if idx != -1:
			AudioServer.set_bus_volume_db(idx, linear_to_db(data["audio"][bus_key]))


func _apply_language() -> void:
	var code: String = String(data["text"]["language"])
	if code == "" or TranslationServer.get_locale() == code:
		return
	VNLocale.set_language(code)


func _parse_size(text: String) -> Vector2i:
	var parts: PackedStringArray = text.split("x")
	if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
		return Vector2i.ZERO
	return Vector2i(parts[0].to_int(), parts[1].to_int())


func _load_settings() -> void:
	if not FileAccess.file_exists(VNPaths.settings_file()):
		return

	var file: FileAccess = FileAccess.open(VNPaths.settings_file(), FileAccess.READ)
	var json_str: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	if json.parse(json_str) != OK:
		VNLog.warn("VNSettings", "settings.json could not be parsed, using defaults")
		return

	var loaded_data: Variant = json.get_data()
	if not loaded_data is Dictionary:
		VNLog.warn("VNSettings", "settings.json has an unexpected shape, using defaults")
		return
	for category: Variant in loaded_data.keys():
		if not data.has(category):
			continue
		if data[category] is Dictionary and loaded_data[category] is Dictionary:
			for key: Variant in loaded_data[category].keys():
				data[category][key] = loaded_data[category][key]
		else:
			data[category] = loaded_data[category]
