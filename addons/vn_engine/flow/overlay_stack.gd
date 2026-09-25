class_name OverlayStack
extends RefCounted
const BUILTIN_OVERLAYS: Dictionary = {
	&"settings": "res://addons/vn_engine/ui/scenes/settings_panel.tscn",
	&"load": "res://addons/vn_engine/ui/scenes/load_panel.tscn",
	&"gallery": "res://addons/vn_engine/ui/scenes/gallery_panel.tscn",
	&"log": "res://addons/vn_engine/ui/scenes/log_ui.tscn",
	&"confirm": "res://addons/vn_engine/ui/scenes/confirm_dialog.tscn",
}

var _layer: CanvasLayer
var _screen_stack: ScreenStack
var _overrides: Dictionary = {}
var _stack: Array[Control] = []


func _init(layer: CanvasLayer, screen_stack: ScreenStack, overrides: Dictionary = {}) -> void:
	_layer = layer
	_screen_stack = screen_stack
	_overrides = overrides


func scene_for(id: StringName) -> PackedScene:
	var custom: PackedScene = _overrides.get(id) as PackedScene
	if custom != null:
		return custom
	if BUILTIN_OVERLAYS.has(id):
		return load(BUILTIN_OVERLAYS[id]) as PackedScene
	return null


func is_empty() -> bool:
	return _stack.is_empty()


func top_overlay() -> Control:
	if _stack.is_empty():
		return null
	return _stack.back()


func open_overlay(id: StringName, params: Dictionary = {}) -> Control:
	var scene: PackedScene = scene_for(id)
	if scene == null:
		VNLog.warn("OverlayStack", "Unknown overlay id: '%s'" % id)
		return null

	if _stack.is_empty():
		var current: VNScreen = _screen_stack.current_screen()
		if current != null:
			current.on_blur()
	else:
		var below: Control = _stack.back()
		below.mouse_filter = Control.MOUSE_FILTER_IGNORE
		below.hide()

	var overlay: Control = scene.instantiate() as Control

	_layer.add_child(overlay)

	if overlay is ColorRect:
		var manifest: GameManifest = VNGame.get_manifest()
		var ui_def: UiDef = manifest.get_ui() if manifest != null else UiDef.new()
		(overlay as ColorRect).color = ui_def.overlay_backdrop_color

	if params.has("asset_resolver") and overlay.has_method("set_asset_resolver"):
		overlay.set_asset_resolver(params.asset_resolver)

	if params.has("runner") and overlay.has_method("set_runner"):
		overlay.set_runner(params.runner)

	if overlay.has_method("configure"):
		overlay.configure(params)

	if overlay.has_method("open_panel"):
		if params.has("save_mode"):
			overlay.open_panel(params.save_mode)
		else:
			overlay.open_panel()

	if overlay.has_signal("closed"):
		overlay.closed.connect(close_overlay)

	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_stack.push_back(overlay)
	return overlay


func close_overlay() -> void:
	if _stack.is_empty():
		return

	var top: Control = _stack.pop_back()
	_layer.remove_child(top)
	top.queue_free()

	if _stack.is_empty():
		var current: VNScreen = _screen_stack.current_screen()
		if current != null:
			current.on_focus()
	else:
		var new_top: Control = _stack.back()
		new_top.mouse_filter = Control.MOUSE_FILTER_STOP
		new_top.show()
