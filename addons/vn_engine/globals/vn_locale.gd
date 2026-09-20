extends Node

## Translation not fully implemented

signal locale_changed(code: String)

var locale_themes: Dictionary = {}

func set_language(code: String) -> void:
	TranslationServer.set_locale(code)
	apply_theme_for_locale(code)
	locale_changed.emit(code)


func get_language() -> String:
	return TranslationServer.get_locale()


func apply_theme_for_locale(code: String) -> void:
	if not locale_themes.has(code):
		return

	var theme: Theme = locale_themes[code]
	if theme == null:
		return

	get_tree().root.theme = theme
