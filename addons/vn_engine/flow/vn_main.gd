class_name VNEngineMain
extends Node

var screen_stack: VNEngineScreenStack
var overlay_stack: VNEngineOverlayStack

@onready var screen_layer: CanvasLayer = $ScreenLayer
@onready var overlay_layer: CanvasLayer = $OverlayLayer
@onready var transition_layer: CanvasLayer = $TransitionLayer
@onready var system_layer: CanvasLayer = $SystemLayer
@onready var systems: Node = $Systems
@onready var persistent_audio: VNEngineAudioSystem = $Systems/PersistentAudio
@onready var dev_overlay: VNEngineDevOverlay = $SystemLayer/DevOverlay


const DEFAULT_THEME_PATH := "res://addons/vn_engine/themes/vn_default.tres"


static var _current: VNEngineMain = null


func _enter_tree() -> void:
	_current = self


func _exit_tree() -> void:
	if _current == self:
		_current = null


func _ready() -> void:
	VNGame.start_engine()
	var engine_theme: Theme = null
	if str(ProjectSettings.get_setting("gui/theme/custom", "")) == "":
		engine_theme = load(DEFAULT_THEME_PATH)
	var ui: VNEngineUiDef = VNGame.get_ui()
	screen_stack = VNEngineScreenStack.new(screen_layer, ui.screens, engine_theme)
	overlay_stack = VNEngineOverlayStack.new(overlay_layer, screen_stack, ui.overlays, engine_theme)

	if not OS.is_debug_build():
		dev_overlay.queue_free()
		dev_overlay = null

	screen_stack.push_screen(VNGame.start_screen())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		if dev_overlay != null:
			dev_overlay.visible = not dev_overlay.visible
			get_viewport().set_input_as_handled()
		return

	if not event.is_action_pressed(&"ui_cancel"):
		return

	if not overlay_stack.is_empty():
		var top: Control = overlay_stack.top_overlay()
		var consumed: bool = false
		if top != null and top.has_method("handle_back"):
			consumed = top.handle_back()
		if not consumed:
			overlay_stack.close_overlay()
		get_viewport().set_input_as_handled()
		return

	var current: VNEngineScreen = screen_stack.current_screen()
	if current != null:
		current.handle_back()
	get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed(VNEngineInput.ALT_CLICK):
		return

	if not overlay_stack.is_empty():
		var top: Control = overlay_stack.top_overlay()
		var consumed: bool = false
		if top != null and top.has_method("handle_back"):
			consumed = top.handle_back()
		if not consumed:
			overlay_stack.close_overlay()
		get_viewport().set_input_as_handled()
		return

	var current_screen: VNEngineScreen = screen_stack.current_screen()
	if current_screen != null and current_screen.handle_alt_click():
		get_viewport().set_input_as_handled()


static func instance() -> VNEngineMain:
	return _current


func get_card_overlay() -> VNEngineCardOverlay:
	return system_layer.get_node_or_null("CardOverlay") as VNEngineCardOverlay
