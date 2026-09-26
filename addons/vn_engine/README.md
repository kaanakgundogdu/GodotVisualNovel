# VN Engine

A small visual novel engine for Godot 4.4. You write the story in plain
text scenario files and set up the game with `.tres` resources in the
Inspector. The engine does the rest. 
Currently dialogue, characters, backgrounds,
choices, flags, save and load, backlog, auto and skip, gallery, endings
and credits supported.

Note: so far the engine is tested only inside the Godot 4.4 editor.
Exported builds are not tested yet.

The plugin adds nothing to your project. No autoloads, no project
settings, no main scene change. If you don't use it, it does nothing.

## Try the demo

1. Copy the `addons/vn_engine/` folder into your project. Keep the same path
   (`res://addons/vn_engine/`), the engine files use it.
2. Open `addons/vn_engine/sample_game/play_sample_game.tscn`.
3. Run that scene.

The sample game is very small. Two chapters of text with choices, flags
and two endings. You don't need to enable the plugin for this.

## Add it to your own game

A game is a folder with the same shape as `sample_game/`:

```
res://my_game/
  config/      game.tres and the other .tres files (chapters, characters, endings ...)
  scenario/    one folder per chapter with .txt scenario files
  assets/      your images, music and videos
```

The easiest start is to copy `sample_game/` and change it.
There is no guide for the scenario syntax yet. Read
`sample_game/scenario/chapter1/scenario1.txt`, it shows the basics.

The engine runs inside one scene: `res://addons/vn_engine/src/flow/scenes/vn_main.tscn`.
When this scene is in the tree, the engine works. When it is removed,
the engine is gone.  Root of the scene or the root node has these settings in the Inspector:

| Setting | Default | What it is |
|---|---|---|
| `content_root` | `res://addons/vn_engine/sample_game/` | Your game folder |
| `save_folder` | `user://vn_engine/{game_id}/saves/` | Where save slots go |
| `settings_file` | `user://vn_engine/{game_id}/settings.json` | Player settings (volume, text speed, keys) |
| `verbose_log` | off | Extra logs in debug builds |
| `design_resolution` | `1920x1080` | Resolution the engine UI is drawn for |
| `manage_window_scaling` | on | Scale the window to `design_resolution` while the VN runs |

`{game_id}` is the `game_id` in your `game.tres`. So every game gets its
own saves and settings, and the engine never writes over your own save
files.

See [Config files](#config-files) for what each file does.

Pick one of these ways to start it.

### 1. The VN is the whole game

Create a new scene from `vn_main.tscn` (**Scene > New Inherited Scene**),
set `content_root` to your folder and make it your main scene. The demo
scene `play_sample_game.tscn` is made this way.

### 2. Start it from code

Set the values before you add the node to the tree:

```gdscript
const VN_SCENE := preload("res://addons/vn_engine/src/flow/scenes/vn_main.tscn")

func start_vn() -> void:
	var vn: VNEngineMain = VN_SCENE.instantiate()
	vn.content_root = "res://my_game/"
	add_child(vn)
```


## Config files


A `.tres` file is a Godot resource saved as text. It keeps data, not code.
Double click it in the folder and edit it in the inspector.
Each config file uses one engine class from `src/defs/`. A file that starts
with `_` is a list: it only collects the other files in its folder.

Note: Maybe making these config files was terrible solution but for now it looks ok.

```
config/
  game.tres
  chapters/      chapter1.tres, chapter2.tres ...
  characters/    _characters.tres, qaan.tres, ely.tres ...
  flags/         _flags.tres, warmth.tres ...
  endings/       ending_warm.tres, ending_plain.tres ...
  credits/       _credits.tres, 01_story.tres ...
  asset_map/     _asset_map.tres, background.tres ...
  screens/       title.tres
                 extras.tres, ui.tres   (optional)
  boot/          _boot.tres, 01_logo.tres ...   (optional)
```

| File | Class | What it does |
|---|---|---|
| `game.tres` | `VNEngineGameManifest` | The main file. Game id, first chapter and links to all the lists. |
| `boot/_boot.tres` | `VNEngineBootDef` | Optional. List of splash screens before the title. |
| `boot/01_logo.tres` | `VNEngineBootScreenDef` | One splash screen: an image or a video, how long it stays, fade time. |
| `chapters/chapter1.tres` | `VNEngineChapterDef` | One chapter: title, scenario file, intro, music, next chapter or branches. |
| `characters/_characters.tres` | `VNEngineCast` | List of all characters. |
| `characters/qaan.tres` | `VNEngineCastMember` | One character: id for scenarios, shown name, name color, default sprite. |
| `flags/_flags.tres` | `VNEngineFlagList` | List of all flags (story variables). |
| `flags/warmth.tres` | `VNEngineFlagDef` | One flag: type, start value, scope (one save or global), min and max. |
| `endings/ending_warm.tres` | `VNEngineEndingDef` | One ending: how to reach it, CG, music, credits and what it unlocks. |
| `credits/_credits.tres` | `VNEngineCreditsDef` | Credits screen: scrolling or video, speed, music and its sections. |
| `credits/01_story.tres` | `VNEngineCreditsSection` | One credits block: a role and its names. |
| `asset_map/_asset_map.tres` | `VNEngineAssetMap` | List of asset folders. |
| `asset_map/background.tres` | `VNEngineAssetMapEntry` | Folder and file types for one asset kind, so scenarios can use short names. |
| `screens/title.tres` | `VNEngineTitleScreenDef` | Title screen: background, music, logo, menu place, when to show Extras and Chapter Select. |
| `screens/extras.tres` | `VNEngineExtrasDef` | Optional. Extras menu: which pages to show and how locked items look. |
| `screens/ui.tres` | `VNEngineUiDef` | Optional. Small UI options: confirm dialogs, backdrop color, name colors in the log. |

`sample_game/config/` is the simplest working set. It has no `boot`, `extras`
or `ui` files, so these are not needed to start.


## Resolution

The engine UI is made for 1920x1080 (16:9).


## Using the engine from code

Call functions to do things. Listen to signals when you want to know
the result.

| What | How |
|---|---|
| Game flow (chapters, endings, title) | `VNEngineMain.game()` |
| Save and load slots | `VNEngineMain.saves().save_game(state, slot)` |
| Unlocks, global flags, seen lines | `VNEngineMain.save_data()` |
| Player settings | `VNEngineMain.settings()` |
| Files of the running game | `VNEnginePaths` |

All of them belong to the running VN. They are loaded when it starts,
written to disk when it closes, and return `null` when no VN is running.

Useful signals: `saved(slot_id)` and `loaded(slot_id)` on `saves()`,
`returned_to_title` and `quit_requested` on `game()`, `global_changed`
on `save_data()`.

## License

MIT, see `LICENSE`.
