@tool
extends EditorPlugin

const REPORT_DIR_KEY := "vn_engine/tools/report_dir"
const REPORT_DIR_DEFAULT := "res://vn_engine_reports/"


func _enter_tree() -> void:
	_register_setting(VNPaths.SETTING_KEY, TYPE_STRING, VNPaths.DEFAULT_ROOT, PROPERTY_HINT_DIR)
	_register_setting(REPORT_DIR_KEY, TYPE_STRING, REPORT_DIR_DEFAULT, PROPERTY_HINT_DIR)
	_register_setting(VNLog.SETTING_VERBOSE, TYPE_BOOL, false, PROPERTY_HINT_NONE)


func _exit_tree() -> void:
	pass


func _register_setting(setting_name: String, type: int, default_value: Variant, hint: int) -> void:
	var is_new: bool = not ProjectSettings.has_setting(setting_name)
	if is_new:
		ProjectSettings.set_setting(setting_name, default_value)
		ProjectSettings.set_initial_value(setting_name, default_value)

	ProjectSettings.add_property_info({
		"name": setting_name,
		"type": type,
		"hint": hint,
	})

	if is_new:
		ProjectSettings.save()
