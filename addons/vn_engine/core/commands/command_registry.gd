@tool
class_name VNEngineCommandRegistry
extends RefCounted

const COMMANDS_DIR := "res://addons/vn_engine/core/commands/"

const NAMES: PackedStringArray = [
	"bg", "cg", "cg_hide", "show", "hide", "leave", "move", "shake",
	"transition", "window",
	"music", "bgm_stop", "sfx", "voice", "movie",
	"set_var", "flag", "jump", "jump_if", "call", "return", "scene", "wait",
	"end", "goto_chapter", "credits", "choice_timer",
	"chapter_title", "eyecatch", "datecard",
]


static func known_names() -> PackedStringArray:
	return NAMES


static func is_known(command_name: String) -> bool:
	return NAMES.has(command_name)


static func script_path(command_name: String) -> String:
	return COMMANDS_DIR + "cmd_%s.gd" % command_name


static func register_all(bus: VNEngineCommandBus) -> void:
	for command_name in NAMES:
		var script: GDScript = load(script_path(command_name)) as GDScript
		var cmd: VNEngineCommand = script.new() as VNEngineCommand
		bus.register(cmd)
