@tool
extends EditorPlugin

const REPORT_DIR_KEY := "vn_engine/tools/report_dir"
const REPORT_DIR_DEFAULT := "res://vn_engine_reports/"

const AUTOLOADS: Array[Array] = [
	["VNSave", "res://addons/vn_engine/globals/vn_save.gd"],
	["VNSettings", "res://addons/vn_engine/globals/vn_settings.gd"],
	["VNLocale", "res://addons/vn_engine/globals/vn_locale.gd"],
	["VNGame", "res://addons/vn_engine/flow/vn_game.gd"],
]


func _enter_tree() -> void:
	_register_setting(VNEnginePaths.SETTING_KEY, TYPE_STRING, VNEnginePaths.DEFAULT_ROOT, PROPERTY_HINT_DIR)
	_register_setting(REPORT_DIR_KEY, TYPE_STRING, REPORT_DIR_DEFAULT, PROPERTY_HINT_DIR)
	_register_setting(VNEngineLog.SETTING_VERBOSE, TYPE_BOOL, false, PROPERTY_HINT_NONE)


func _exit_tree() -> void:
	pass


func _enable_plugin() -> void:
	for entry: Array in AUTOLOADS:
		var autoload_name: String = entry[0]
		var autoload_path: String = entry[1]
		if not ProjectSettings.has_setting("autoload/" + autoload_name):
			add_autoload_singleton(autoload_name, autoload_path)


func _disable_plugin() -> void:
	for entry: Array in AUTOLOADS:
		var autoload_name: String = entry[0]
		if ProjectSettings.has_setting("autoload/" + autoload_name):
			remove_autoload_singleton(autoload_name)


func _register_setting(setting_name: String, type: int, default_value: Variant, hint: int) -> void:
	if not ProjectSettings.has_setting(setting_name):
		ProjectSettings.set_setting(setting_name, default_value)

	ProjectSettings.set_initial_value(setting_name, default_value)
	ProjectSettings.add_property_info({
		"name": setting_name,
		"type": type,
		"hint": hint,
	})
