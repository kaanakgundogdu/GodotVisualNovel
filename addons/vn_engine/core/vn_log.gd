@tool
class_name VNLog
extends RefCounted

const SETTING_VERBOSE := "vn_engine/debug/verbose_log"


static func debug(tag: String, message: String) -> void:
	if OS.is_debug_build() and bool(ProjectSettings.get_setting(SETTING_VERBOSE, false)):
		print(_format(tag, message))


static func info(tag: String, message: String) -> void:
	print(_format(tag, message))


static func warn(tag: String, message: String) -> void:
	push_warning(_format(tag, message))


static func error(tag: String, message: String) -> void:
	push_error(_format(tag, message))


static func _format(tag: String, message: String) -> String:
	return "[%s] %s" % [tag, message]
