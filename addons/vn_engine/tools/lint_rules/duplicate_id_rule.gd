@tool
class_name DuplicateIdRule
extends AssetLintRule


func title() -> String:
	return "10. Duplicate ids"


func run(ctx: AssetLintContext) -> void:
	var manifest: GameManifest = ctx.manifest
	if manifest == null:
		ctx.info("GameManifest could not be loaded, rule skipped")
		return

	_check_duplicates(ctx, "ChapterDef", _chapter_ids(manifest))
	_check_duplicates(ctx, "EndingDef", _ending_ids(manifest))


func _chapter_ids(manifest: GameManifest) -> Array[String]:
	var out: Array[String] = []
	for chapter in manifest.chapters:
		if chapter != null:
			out.append(chapter.id)
	return out


func _ending_ids(manifest: GameManifest) -> Array[String]:
	var out: Array[String] = []
	for ending in manifest.endings:
		if ending != null:
			out.append(ending.id)
	return out


func _check_duplicates(ctx: AssetLintContext, label: String, ids: Array[String]) -> void:
	var seen: Dictionary = {}
	for id in ids:
		var key: String = id.to_lower()
		if seen.has(key):
			ctx.error("Two %ss share the id '%s' (case-insensitive)" % [label, id])
		else:
			seen[key] = true
