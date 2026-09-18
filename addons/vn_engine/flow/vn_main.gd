class_name VNMain
extends Node

var persistent_audio: AudioSystem
var dev_overlay: DevOverlay = null

var screen_stack: ScreenStack
var overlay_stack: OverlayStack

@onready var screen_layer: CanvasLayer = $ScreenLayer
@onready var overlay_layer: CanvasLayer = $OverlayLayer
@onready var transition_layer: CanvasLayer = $TransitionLayer
@onready var system_layer: CanvasLayer = $SystemLayer
@onready var systems: Node = $Systems


func _ready() -> void:
	screen_stack = ScreenStack.new(screen_layer)
	overlay_stack = OverlayStack.new(overlay_layer, screen_stack)

	var audio_scene: PackedScene = load("res://addons/vn_engine/systems/scenes/audio_system.tscn") as PackedScene
	persistent_audio = audio_scene.instantiate() as AudioSystem
	systems.add_child.call_deferred(persistent_audio)

	if OS.is_debug_build():
		var dev_overlay_scene: PackedScene = load("res://addons/vn_engine/ui/scenes/dev_overlay.tscn") as PackedScene
		dev_overlay = dev_overlay_scene.instantiate() as DevOverlay
		dev_overlay.hide()
		system_layer.add_child.call_deferred(dev_overlay)

	var start_screen: StringName = &"title"
	if VNGame.manifest != null and VNGame.manifest.has_boot_sequence():
		start_screen = &"opening"
	screen_stack.push_screen(start_screen)


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

	var current: VNScreen = screen_stack.current_screen()
	if current != null:
		current.handle_back()
	get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"vn_alt_click"):
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

	var current_screen: VNScreen = screen_stack.current_screen()
	if current_screen != null and current_screen.handle_alt_click():
		get_viewport().set_input_as_handled()


static func instance() -> VNMain:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("VNMain") as VNMain


func get_card_overlay() -> CardOverlay:
	return system_layer.get_node_or_null("CardOverlay") as CardOverlay
