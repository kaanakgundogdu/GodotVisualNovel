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

1. Copy the `addons/vn_engine/` folder into your project.
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

The engine runs inside one scene: `res://addons/vn_engine/flow/scenes/vn_main.tscn`.
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

The configuration part is little bit tricky but I made it that way to make it easier to use.
Explore already existing configs and you can copy from your project to make changes.

Pick one of these ways to start it.

### 1. The VN is the whole game

Create a new scene from `vn_main.tscn` (**Scene > New Inherited Scene**),
set `content_root` to your folder and make it your main scene. The demo
scene `play_sample_game.tscn` is made this way.

### 2. Start it from code

Set the values before you add the node to the tree:

```gdscript
const VN_SCENE := preload("res://addons/vn_engine/flow/scenes/vn_main.tscn")

func start_vn() -> void:
	var vn: VNEngineMain = VN_SCENE.instantiate()
	vn.content_root = "res://my_game/"
	add_child(vn)
```


## Resolution

The engine UI is made for 1920x1080 (16:9). You don't need to change
Project Settings for it. While `vn_main` is running it scales the window
to fit that size (`canvas_items`, `keep`) and puts your old values back
when it is removed.


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
