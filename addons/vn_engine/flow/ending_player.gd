class_name EndingPlayer
extends RefCounted


func present(root: VNMain, ending: EndingDef, stage: VNStageScreen, shared_resolver: AssetResolver) -> void:
	var overlay: CardOverlay = root.get_card_overlay()
	var opened: bool = false

	if ending.ed_movie != "":
		var movie_resolver: AssetResolver = _resolver_for(stage, shared_resolver)
		var movie_path: String = movie_resolver.resolve("movie", ending.ed_movie) if movie_resolver != null else ""
		if movie_path != "":
			overlay.open(CardOverlay.MODE_MOVIE, {"movie_path": movie_path, "movie_id": ending.ed_movie, "hold_on_close": true})
			opened = true

	if not opened and ending.cg != "":
		var image_resolver: AssetResolver = _resolver_for(stage, shared_resolver)
		var image_path: String = image_resolver.resolve("cg", ending.cg) if image_resolver != null else ""
		if image_path != "":
			overlay.open(CardOverlay.MODE_IMAGE, {"image_path": image_path, "hold_on_close": true}, ending.card_duration)
			opened = true

	if not opened:
		overlay.open(CardOverlay.MODE_TITLE, {"title": tr(ending.title_key), "hold_on_close": true}, ending.card_duration)

	if ending.bgm != "":
		var bgm_path: String = shared_resolver.resolve("music", ending.bgm)
		if bgm_path != "":
			root.persistent_audio.play_bgm(bgm_path)

	await overlay.finished


func release(root: VNMain) -> void:
	root.get_card_overlay().release()


func _resolver_for(stage: VNStageScreen, shared_resolver: AssetResolver) -> AssetResolver:
	if stage != null and stage.story_runner != null and stage.story_runner.ctx != null:
		return stage.story_runner.ctx.assets
	return shared_resolver
