@tool
class_name GameManifest
extends Resource

@export_group("Identity")
## Unique id for this game, like "my_first_vn". Used to separate save
## files between games.
@export var game_id: String = ""
## Translation key for the game's title.
@export var title_key: String = ""
## Game version, like "0.1.0".
@export var version: String = "0.1.0"

@export_group("Flow")
## ChapterDef.id a new game starts on.
@export var first_chapter: String = ""
## Fallback ending id used when the story ends without @end.
@export var default_ending: String = ""
## Add one ChapterDef per chapter in the game.
@export var chapters: Array[ChapterDef] = []
## Add one EndingDef per ending in the game.
@export var endings: Array[EndingDef] = []

@export_group("Content")
## Boot sequence played before the title screen. null means no
## splash/opening.
@export var boot: BootDef
## All flag and counter definitions for this game.
@export var flags: FlagList

## Credits screen definition.
@export var credits: CreditsDef

@export_group("Screens")
## Title screen definition.
@export var title: TitleScreenDef
## Extras screen definition. null means default extras behaviour.
@export var extras: ExtrasDef
## Engine UI behaviour tuning. null means default UI behaviour.
@export var ui: UiDef

@export_group("Localization")
## Locale codes offered in the language menu, like ["tr", "en"]. Fewer
## than two locales hides the language tab.
@export var locales: PackedStringArray = ["tr", "en"]

func get_boot() -> BootDef:
	return boot if boot != null else BootDef.new()

func has_boot_sequence() -> bool:
	return get_boot().has_sequence()

func get_extras() -> ExtrasDef:
	return extras if extras != null else ExtrasDef.new()

func get_ui() -> UiDef:
	return ui if ui != null else UiDef.new()

func find_chapter(id: String) -> ChapterDef:
	var key: String = id.to_lower()
	for chapter: ChapterDef in chapters:
		if chapter == null:
			continue
		if chapter.id.to_lower() == key:
			return chapter
	return null

func find_ending(id: String) -> EndingDef:
	var key: String = id.to_lower()
	for ending: EndingDef in endings:
		if ending == null:
			continue
		if ending.id.to_lower() == key:
			return ending
	return null
