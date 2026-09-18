class_name ScreenStack
extends RefCounted

const SCREEN_PATHS: Dictionary = {
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
var _current: VNScreen = null
var _current_id: StringName = &""
var _current_params: Dictionary = {}
var _stack: Array[Dictionary] = []


func _init(layer: CanvasLayer) -> void:
	_layer = layer


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
	if not SCREEN_PATHS.has(id):
		VNLog.warn("ScreenStack", "Unknown screen id: '%s'" % id)
		return null

	if _current != null:
		_current.exit()
		_layer.remove_child(_current)
		_current.queue_free()

	var path: String = SCREEN_PATHS[id]
	var scene: PackedScene = load(path) as PackedScene
	var screen: VNScreen = scene.instantiate() as VNScreen
	_layer.add_child(screen)
	_current = screen
	_current_id = id
	_current_params = params
	screen.enter(params)
	screen.on_focus()
	return screen
