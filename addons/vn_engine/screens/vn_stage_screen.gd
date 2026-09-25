class_name VNStageScreen
extends VNScreen


@onready var story_runner: StoryRunner = $StoryRunner
@onready var in_game_buttons: InGameButtons = $CanvasLayer/InGameButtons


func _ready() -> void:
	VNMain.instance().persistent_audio.attach_runner(story_runner)

	in_game_buttons.save_menu_requested.connect(_on_save_menu_requested)
	in_game_buttons.load_menu_requested.connect(_on_load_menu_requested)
	in_game_buttons.settings_requested.connect(_on_settings_requested)
	in_game_buttons.log_requested.connect(_on_log_requested)

	story_runner.story_ended.connect(_on_story_ended)

	story_runner.state_restored.connect(_on_state_restored)

	story_runner.parse_diagnostics_ready.connect(_on_parse_diagnostics_ready)


func screen_id() -> StringName:
	return &"stage"


func enter(params: Dictionary) -> void:
	story_runner.flag_list = VNGame.get_flag_list()

	if VNSave.slot_to_load != -1:
		var slot: int = VNSave.slot_to_load
		VNSave.slot_to_load = -1
		story_runner.execute_load_game(slot)
	else:
		var file: String = params.get("story_file", "")
		if file == "":
			VNLog.error("VNStageScreen", "enter() called without a 'story_file' parameter")
			return

		var resume_state: Dictionary = params.get("resume_state", {})
		if not resume_state.is_empty():
			story_runner.state.from_dict(resume_state)

		var chapter_id_param: String = params.get("chapter_id", "")
		if chapter_id_param != "":
			story_runner.state.chapter_id = chapter_id_param

		_apply_chapter_bgm(params.get("chapter_bgm", ""))

		if chapter_id_param != "":
			await _maybe_show_chapter_intro(chapter_id_param)

		VNGame.seed_flags(story_runner.state)
		story_runner.start_story(file)
		_autosave_on_chapter_enter(chapter_id_param)


func exit() -> void:
	VNMain.instance().persistent_audio.detach_runner()


func on_blur() -> void:
	if story_runner.is_auto or story_runner.is_skip:
		story_runner.is_auto = false
		story_runner.is_skip = false
		story_runner.mode_changed.emit()


func _on_story_ended() -> void:
	VNGame.on_story_ended(story_runner.end_reason, story_runner.end_ending_id, story_runner.state)


func _on_state_restored(state: StoryState) -> void:
	VNGame.backfill_chapter_id(state)
	VNGame.seed_flags(state)


func _on_parse_diagnostics_ready(diagnostics: Array) -> void:
	var source: String = ""
	if story_runner.script_res != null:
		source = story_runner.script_res.source_path
	var source_name: String = source.get_file() if source != "" else "(unknown source)"

	var should_log: bool = VNGame.should_log_diagnostics(source)
	var has_error: bool = false
	for entry in diagnostics:
		var diag: ParseDiagnostic = entry as ParseDiagnostic
		if diag == null:
			continue
		if diag.severity == ParseDiagnostic.Severity.ERROR:
			has_error = true
		if not should_log:
			continue
		match diag.severity:
			ParseDiagnostic.Severity.ERROR:
				VNLog.error("VNStageScreen", "%s: %s" % [source_name, diag.format()])
			ParseDiagnostic.Severity.WARNING:
				VNLog.warn("VNStageScreen", "%s: %s" % [source_name, diag.format()])
			_:
				VNLog.debug("VNStageScreen", "%s: %s" % [source_name, diag.format()])

	if not has_error:
		return

	var root: VNMain = VNMain.instance()
	if root.screen_stack.current_id() == &"diagnostics":
		return

	if not VNGame.should_report_diagnostics(source):
		return

	root.screen_stack.push_screen(&"diagnostics", {"diagnostics": diagnostics, "source": source})


func _on_save_menu_requested() -> void:
	_open_load_panel(true)


func _on_load_menu_requested() -> void:
	_open_load_panel(false)


func _on_settings_requested() -> void:
	VNGame.open_overlay(&"settings")


func _on_log_requested() -> void:
	VNGame.open_overlay(&"log", {"runner": story_runner})


func _open_load_panel(save_mode: bool) -> void:
	var panel: Control = VNGame.open_overlay(&"load", {"save_mode": save_mode})
	panel.load_requested.connect(_on_load_slot_requested)
	panel.save_requested.connect(_on_save_slot_requested)


func _on_load_slot_requested(slot_id: int) -> void:
	VNGame.close_overlay()
	story_runner.execute_load_game(slot_id)


func _on_save_slot_requested(slot_id: int) -> void:
	VNGame.close_overlay()

	await get_tree().process_frame
	await get_tree().process_frame

	VNSave.save_game(story_runner.state, slot_id)
	_open_load_panel(true)


func _apply_chapter_bgm(bgm_id: String) -> void:
	if bgm_id == "":
		return
	story_runner.state.audio["music"] = bgm_id
	if story_runner.ctx.audio:
		story_runner.ctx.audio.play_channel("music", bgm_id)


func _autosave_on_chapter_enter(chapter_id: String) -> void:
	if chapter_id == "":
		return

	var manifest: GameManifest = VNGame.get_manifest()
	var chapter: ChapterDef = manifest.find_chapter(chapter_id) if manifest != null else null
	if chapter == null:
		return

	if not chapter.autosave_on_enter:
		return
	if not bool(VNSettings.data.get("autosave", true)):
		return

	await get_tree().process_frame
	await get_tree().process_frame
	VNSave.save_game(story_runner.state, VNSave.AUTOSAVE_SLOT)


func _maybe_show_chapter_intro(chapter_id: String) -> void:
	var manifest: GameManifest = VNGame.get_manifest()
	if manifest == null:
		return

	var chapter: ChapterDef = manifest.find_chapter(chapter_id)
	if chapter == null:
		return

	if chapter.intro_style == "none":
		return

	var overlay: CardOverlay = VNMain.instance().get_card_overlay()
	var mode: String = CardOverlay.MODE_TITLE
	var card_params: Dictionary = {"title": tr(chapter.title_key), "subtitle": tr(chapter.subtitle_key)}

	if chapter.intro_style == "eyecatch":
		var image_path := ""
		if story_runner.ctx != null and story_runner.ctx.assets != null and chapter.intro_background != "":
			image_path = story_runner.ctx.assets.resolve("cg", chapter.intro_background)
			if image_path == "":
				image_path = story_runner.ctx.assets.resolve("background", chapter.intro_background)
		if image_path != "":
			mode = CardOverlay.MODE_IMAGE
			card_params = {"image_path": image_path}
		else:
			VNLog.warn("VNStageScreen", "intro_style='eyecatch' but intro_background ('%s') could not be resolved, falling back to title card" % chapter.intro_background)

	overlay.open(mode, card_params, chapter.intro_duration)
	await overlay.finished
