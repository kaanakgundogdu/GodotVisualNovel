class_name VNText
extends RefCounted

## This class tries to find a translation. Otherwise, it falls back to the raw text.
## TODO: Translation not fully implemented yet

static func speaker_name(speaker_id: String) -> String:
	if speaker_id.capitalize().is_empty():
		return ""

	var speaker_text: String = speaker_id.capitalize().to_upper()
	var name_key: String = "char.%s.name" % speaker_id
	var translated_name: String = String(TranslationServer.translate(name_key))
	if translated_name != name_key:
		speaker_text = translated_name
	return speaker_text


static func line_text(line_id: String, fallback: String) -> String:
	if line_id == "":
		return fallback

	var translated: String = String(TranslationServer.translate(line_id))
	if translated != line_id:
		return translated
	return fallback
