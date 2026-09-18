class_name VNCommand
extends RefCounted

func command_name() -> String:
	return ""

func allows_multiple() -> bool:
	return false

func validate(_args: String, _ctx: CommandContext) -> String:
	return ""

func apply(_args: String, _ctx: CommandContext) -> void:
	pass

func is_blocking() -> bool:
	return false
