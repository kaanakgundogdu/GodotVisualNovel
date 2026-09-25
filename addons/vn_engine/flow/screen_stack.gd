class_name ScreenStack
extends RefCounted

const BUILTIN_SCREENS: Dictionary = {
	&"title": "res://addons/vn_engine/screens/scenes/title_screen.tscn",
	&"stage": "res://addons/vn_engine/screens/scenes/vn_stage_screen.tscn",
	&"opening": "res://addons/vn_engine/screens/scenes/opening_screen.tscn",
	&"credits": "res://addons/vn_engine/screens/scenes/credits_screen.tscn",
	&"extras": "res://addons/vn_engine/screens/scenes/extras_screen.tscn",
	&"chapter_select": "res://addons/vn_engine/screens/scenes/chapter_select_screen.tscn",
	&"diagnostics": "res://addons/vn_engine/screens/scenes/diagnostics_screen.tscn",
	&"loading": "res://addons/vn_engine/screens/scenes/loading_screen.tscn",
}

var _layer: CanvasLayer
var _overrides: Dictionary = {}
var _current: VNScreen = null
var _current_id: StringName = &""
var _current_params: Dictionary = {}
var _stack: Array[Dictionary] = []


func _init(layer: CanvasLayer, overrides: Dictionary = {}) -> void:
	_layer = layer
	_overrides = overrides


func has_screen(id: StringName) -> bool:
	return _overrides.has(id) or BUILTIN_SCREENS.has(id)


func scene_path(id: StringName) -> String:
	var custom: PackedScene = _overrides.get(id) as PackedScene
	if custom != null:
		return custom.resource_path
	return BUILTIN_SCREENS.get(id, "")


func current_screen() -> VNScreen:
	return _current


func current_id() -> StringName:
	return _current_id


func push_screen(id: StringName, params: Dictionary = {}) -> VNScreen:
	if _current_id != &"":
		_stack.push_back({"id": _current_id, "params": _current_params})
	return _swap_to(id, params)


func replace_screen(id: StringName, params: Dictionary = {}) -> VNScreen:
	return _swap_to(id, params)


func pop_screen() -> VNScreen:
	if _stack.is_empty():
		return _current
	var prev: Dictionary = _stack.pop_back()
	return _swap_to(prev.id, prev.params)


func _swap_to(id: StringName, params: Dictionary) -> VNScreen:
	var scene: PackedScene = _overrides.get(id) as PackedScene
	if scene == null and BUILTIN_SCREENS.has(id):
		scene = load(BUILTIN_SCREENS[id]) as PackedScene
	if scene == null:
		VNLog.warn("ScreenStack", "Unknown screen id: '%s'" % id)
		return null

	var node: Node = scene.instantiate()
	var screen: VNScreen = node as VNScreen
	if screen == null:
		node.free()
		VNLog.error("ScreenStack", "Screen '%s' must have a VNScreen root" % id)
		return null

	if _current != null:
		_current.exit()
		_layer.remove_child(_current)
		_current.queue_free()

	_layer.add_child(screen)
	_current = screen
	_current_id = id
	_current_params = params
	screen.enter(params)
	screen.on_focus()
	return screen
