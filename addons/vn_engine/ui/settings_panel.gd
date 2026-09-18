class_name SettingsPanel
extends ColorRect

signal closed

const _PREVIEW_SENTENCE: String = "The quick brown fox jumps over the lazy dog."

static var _extra_pages: Array[Dictionary] = []

var _window_size_choices: Array[Vector2i] = []
var _language_codes: Array[String] = []
var _preview_tween: Tween

@onready var close_settings_btn: Button = %CloseSettingsButton
@onready var reset_defaults_btn: Button = %ResetDefaultsButton
@onready var settings_tabs: TabContainer = %SettingsTabs

@onready var fullscreen_toggle: CheckButton = %FullscreenToggle
@onready var window_size_option: OptionButton = %WindowSizeOption
@onready var vsync_toggle: CheckButton = %VsyncToggle

@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var master_volume_label: Label = %MasterVolumeLabel
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var music_volume_label: Label = %MusicVolumeLabel
@onready var sfx_volume_slider: HSlider = %SfxVolumeSlider
@onready var sfx_volume_label: Label = %SfxVolumeLabel
@onready var voice_volume_slider: HSlider = %VoiceVolumeSlider
@onready var voice_volume_label: Label = %VoiceVolumeLabel
@onready var mute_on_focus_loss_toggle: CheckButton = %MuteOnFocusLossToggle

@onready var text_speed_slider: HSlider = %TextSpeedSlider
@onready var text_speed_preview: RichTextLabel = %TextSpeedPreview
@onready var auto_speed_slider: HSlider = %AutoSpeedSlider
@onready var skip_unread_toggle: CheckButton = %SkipUnreadToggle
@onready var dialog_opacity_slider: HSlider = %DialogOpacitySlider
@onready var dialog_opacity_label: Label = %DialogOpacityLabel
@onready var autosave_toggle: CheckButton = %AutosaveToggle

@onready var language_tab_root: Control = %Language
@onready var language_option: OptionButton = %LanguageOption


static func register_page(title: String, scene_path: String) -> void:
	for page: Dictionary in _extra_pages:
		if String(page["title"]) == title:
			return
	_extra_pages.append({"title": title, "scene_path": scene_path})


func _ready() -> void:
	close_settings_btn.pressed.connect(_on_close_pressed)
	reset_defaults_btn.pressed.connect(_on_reset_defaults_pressed)

	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	window_size_option.item_selected.connect(_on_window_size_selected)
	vsync_toggle.toggled.connect(_on_vsync_toggled)

	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	voice_volume_slider.value_changed.connect(_on_voice_volume_changed)
	mute_on_focus_loss_toggle.toggled.connect(_on_mute_on_focus_loss_toggled)

	text_speed_slider.value_changed.connect(_on_text_speed_changed)
	auto_speed_slider.value_changed.connect(_on_auto_speed_changed)
	skip_unread_toggle.toggled.connect(_on_skip_unread_toggled)
	dialog_opacity_slider.value_changed.connect(_on_dialog_opacity_changed)
	autosave_toggle.toggled.connect(_on_autosave_toggled)

	language_option.item_selected.connect(_on_language_selected)


func open_panel() -> void:
	show()
	_add_extra_pages()
	_refresh_controls()
	fullscreen_toggle.grab_focus()


func handle_back() -> bool:
	_save_and_close()
	return true


func _on_close_pressed() -> void:
	_save_and_close()


func _save_and_close() -> void:
	VNSettings.save_settings()
	closed.emit()


func _on_reset_defaults_pressed() -> void:
	VNSettings.reset_to_defaults()
	_refresh_controls()


func _refresh_controls() -> void:
	var settings: Dictionary = VNSettings.data

	fullscreen_toggle.set_pressed_no_signal(bool(settings["display"]["fullscreen"]))
	vsync_toggle.set_pressed_no_signal(bool(settings["display"]["vsync"]))
	_refresh_window_size_option()
	window_size_option.disabled = bool(settings["display"]["fullscreen"])

	master_volume_slider.set_value_no_signal(float(settings["audio"]["master"]))
	master_volume_label.text = _format_percent(float(settings["audio"]["master"]))
	music_volume_slider.set_value_no_signal(float(settings["audio"]["music"]))
	music_volume_label.text = _format_percent(float(settings["audio"]["music"]))
	sfx_volume_slider.set_value_no_signal(float(settings["audio"]["sfx"]))
	sfx_volume_label.text = _format_percent(float(settings["audio"]["sfx"]))
	voice_volume_slider.set_value_no_signal(float(settings["audio"]["voice"]))
	voice_volume_label.text = _format_percent(float(settings["audio"]["voice"]))
	mute_on_focus_loss_toggle.set_pressed_no_signal(bool(settings["audio"]["mute_on_focus_loss"]))

	text_speed_slider.set_value_no_signal(VNSettings.get_text_speed_normalized())
	auto_speed_slider.set_value_no_signal(VNSettings.get_auto_speed_normalized())
	skip_unread_toggle.set_pressed_no_signal(bool(settings["text"]["skip_unread"]))
	dialog_opacity_slider.set_value_no_signal(float(settings["text"]["window_opacity"]))
	dialog_opacity_label.text = _format_percent(float(settings["text"]["window_opacity"]))
	autosave_toggle.set_pressed_no_signal(bool(settings["autosave"]))

	_refresh_language_tab()
	_play_text_speed_preview()


func _refresh_window_size_option() -> void:
	window_size_option.clear()
	var current: Vector2i = VNSettings.get_window_size()
	_window_size_choices = VNSettings.WINDOW_SIZES.duplicate()
	var custom_first: bool = not _window_size_choices.has(current)
	if custom_first:
		_window_size_choices.insert(0, current)

	for i: int in _window_size_choices.size():
		var size: Vector2i = _window_size_choices[i]
		var label: String = "%d x %d" % [size.x, size.y]
		if custom_first and i == 0:
			label = "Custom (%s)" % label
		window_size_option.add_item(label)

	window_size_option.select(_window_size_choices.find(current))


func _refresh_language_tab() -> void:
	var manifest: GameManifest = VNGame.get_manifest()
	var locales: PackedStringArray = manifest.locales if manifest != null else PackedStringArray()
	var hide_tab: bool = locales.size() < 2

	var tab_index: int = settings_tabs.get_tab_idx_from_control(language_tab_root)
	if tab_index != -1:
		settings_tabs.set_tab_hidden(tab_index, hide_tab)
	if hide_tab:
		return

	language_option.clear()
	_language_codes.clear()
	var current: String = String(VNSettings.data["text"]["language"])
	var select_index: int = 0

	for i: int in locales.size():
		var code: String = String(locales[i])
		var display_name: String = TranslationServer.get_locale_name(code)
		if display_name == "":
			display_name = code
		language_option.add_item(display_name)
		_language_codes.append(code)
		if code == current:
			select_index = i

	language_option.select(select_index)


func _play_text_speed_preview() -> void:
	if _preview_tween != null and _preview_tween.is_valid():
		_preview_tween.kill()

	text_speed_preview.text = _PREVIEW_SENTENCE
	text_speed_preview.visible_characters = 0
	var total_chars: int = text_speed_preview.get_parsed_text().length()
	var duration: float = maxf(total_chars * float(VNSettings.data["text"]["speed"]), 0.01)

	_preview_tween = create_tween()
	_preview_tween.tween_property(text_speed_preview, "visible_characters", total_chars, duration)


func _add_extra_pages() -> void:
	for page: Dictionary in _extra_pages:
		var title: String = String(page["title"])
		if _has_tab_named(title):
			continue

		var scene_path: String = String(page["scene_path"])
		var scene: PackedScene = load(scene_path) as PackedScene
		if scene == null:
			VNLog.warn("SettingsPanel", "Failed to load extra page: %s" % scene_path)
			continue

		var page_root: Control = scene.instantiate() as Control
		if page_root == null:
			VNLog.warn("SettingsPanel", "Extra page root is not a Control: %s" % scene_path)
			continue

		page_root.name = title
		settings_tabs.add_child(page_root)


func _has_tab_named(title: String) -> bool:
	for i: int in settings_tabs.get_tab_count():
		if settings_tabs.get_tab_control(i).name == title:
			return true
	return false


func _format_percent(value: float) -> String:
	return "%d%%" % int(round(clampf(value, 0.0, 1.0) * 100.0))


func _on_fullscreen_toggled(button_pressed: bool) -> void:
	VNSettings.data["display"]["fullscreen"] = button_pressed
	window_size_option.disabled = button_pressed
	VNSettings.apply_all_settings()


func _on_window_size_selected(index: int) -> void:
	if index < 0 or index >= _window_size_choices.size():
		return
	VNSettings.set_window_size(_window_size_choices[index])
	VNSettings.apply_all_settings()


func _on_vsync_toggled(button_pressed: bool) -> void:
	VNSettings.data["display"]["vsync"] = button_pressed
	VNSettings.apply_all_settings()


func _on_master_volume_changed(value: float) -> void:
	VNSettings.data["audio"]["master"] = value
	master_volume_label.text = _format_percent(value)
	VNSettings.apply_all_settings()


func _on_music_volume_changed(value: float) -> void:
	VNSettings.data["audio"]["music"] = value
	music_volume_label.text = _format_percent(value)
	VNSettings.apply_all_settings()


func _on_sfx_volume_changed(value: float) -> void:
	VNSettings.data["audio"]["sfx"] = value
	sfx_volume_label.text = _format_percent(value)
	VNSettings.apply_all_settings()


func _on_voice_volume_changed(value: float) -> void:
	VNSettings.data["audio"]["voice"] = value
	voice_volume_label.text = _format_percent(value)
	VNSettings.apply_all_settings()


func _on_mute_on_focus_loss_toggled(button_pressed: bool) -> void:
	VNSettings.data["audio"]["mute_on_focus_loss"] = button_pressed
	VNSettings.apply_all_settings()


func _on_text_speed_changed(value: float) -> void:
	VNSettings.set_text_speed_normalized(value)
	VNSettings.apply_all_settings()
	_play_text_speed_preview()


func _on_auto_speed_changed(value: float) -> void:
	VNSettings.set_auto_speed_normalized(value)
	VNSettings.apply_all_settings()


func _on_skip_unread_toggled(button_pressed: bool) -> void:
	VNSettings.data["text"]["skip_unread"] = button_pressed
	VNSettings.apply_all_settings()


func _on_dialog_opacity_changed(value: float) -> void:
	VNSettings.data["text"]["window_opacity"] = value
	dialog_opacity_label.text = _format_percent(value)
	VNSettings.apply_all_settings()


func _on_autosave_toggled(button_pressed: bool) -> void:
	VNSettings.data["autosave"] = button_pressed
	VNSettings.apply_all_settings()


func _on_language_selected(index: int) -> void:
	if index < 0 or index >= _language_codes.size():
		return
	VNSettings.data["text"]["language"] = _language_codes[index]
	VNSettings.apply_all_settings()
