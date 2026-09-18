@tool
class_name Cast
extends Resource

## One entry per character. Add one CastMember per character in the game.
@export var characters: Array[CastMember] = []


func get_entry(id: String) -> CastMember:
	var key: String = id.to_lower()
	for entry: CastMember in characters:
		if entry == null:
			continue
		if entry.id.to_lower() == key:
			return entry
	return null


func is_narrator(id: String) -> bool:
	var key: String = id.to_lower()
	if key == "narrator":
		return true

	var entry: CastMember = get_entry(key)
	if entry == null:
		return true

	return entry.is_narrator
