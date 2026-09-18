@tool
extends RefCounted
class_name VNPaths


const SETTING_KEY := "vn_engine/content/root"
const DEFAULT_ROOT := "res://game/"

static func content_root() -> String:
	var raw: Variant = ProjectSettings.get_setting(SETTING_KEY, DEFAULT_ROOT)
	var root: String = str(raw).strip_edges()
	if root == "":
		root = DEFAULT_ROOT
	if not root.ends_with("/"):
		root += "/"
	return root

static func config_dir() -> String:
	return content_root() + "config/"

static func manifest() -> String:
	return config_dir() + "game.tres"

static func asset_map() -> String:
	return config_dir() + "asset_map/_asset_map.tres"

static func cast_file() -> String:
	return config_dir() + "characters/_characters.tres"

static func scenario_root() -> String:
	return content_root() + "scenario/"

static func locale_dir() -> String:
	return content_root() + "locale/"

static func line_ids() -> String:
	return locale_dir() + "line_ids.txt"

static func dialog_csv() -> String:
	return locale_dir() + "dialog.csv"
