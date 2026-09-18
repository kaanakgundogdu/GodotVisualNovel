# Globals

The engine's autoloads and its two static helper classes.

## Autoloads vs static classes

Four autoloads, registered by hand in `project.godot`'s `[autoload]`
section (the plugin does not add them, `plugin.gd` only registers project
settings):

```
VNSave="*res://addons/vn_engine/globals/vn_save.gd"
VNSettings="*res://addons/vn_engine/globals/vn_settings.gd"
VNLocale="*res://addons/vn_engine/globals/vn_locale.gd"
VNGame="*res://addons/vn_engine/flow/vn_game.gd"
```

`VNPaths` (`core/vn_paths.gd`) and `VNLog` (`core/vn_log.gd`) are **not**
autoloads. Both `extend RefCounted` and expose only `static func`, called
directly as `VNPaths.manifest()` or `VNLog.warn(tag, msg)` from anywhere,
no node lookup needed.

## VNGame

Owns the manifest and chapter/ending navigation. Covered in depth in
[`FLOW.md`](FLOW.md), this is the quick-reference part.

| Member | What it does |
|---|---|
| `manifest: GameManifest` | Loaded from `config/game.tres` in `_ready()`. Null until that file exists. |
| `start_new_game()` | Starts `manifest.first_chapter`. |
| `goto_chapter(id)` | Chapter transition, see FLOW.md. |
| `load_slot(slot_id)` | Routes to the stage screen with a save to resume. |
| `open_overlay(id, params)` / `close_overlay()` | Opens/closes a panel through `VNMain.overlay_stack`. |
| `get_manifest()` / `get_flag_list()` | Manifest and flag schema accessors. |
| `get_shared_asset_resolver()` | The `AssetResolver` used outside an active chapter (title screen, gallery). |

```gdscript
VNGame.open_overlay(&"settings")
VNGame.start_new_game()
```

No signals on `VNGame`.

## VNSave

Save slots and cross-playthrough global data, under
`user://saves/<namespace>/` (namespace: `GameManifest.game_id` if set,
else the content root folder name).

| Member | What it does |
|---|---|
| `save_game(state, slot_id)` | Writes a save slot plus a thumbnail PNG. |
| `load_game(slot_id)` | Returns the migrated state dict, or `null`. |
| `get_slot_status(slot_id)` | `EMPTY` / `OK` / `CORRUPT` / `UNSUPPORTED`. |
| `AUTOSAVE_SLOT` / `QUICKSAVE_SLOT` | Reserved slot numbers (98, 99). |
| `mark_line_seen(chapter_id, line_id)` / `is_line_seen(...)` | Backlog and skip-seen tracking. |
| `set_global_flag(id, value)` / `get_global_flag(id)` | Global (cross-playthrough) flags. |
| `mark_ending_seen(id)` / `is_ending_seen(id)` | Ending gallery unlocks. |
| `unlock_cg(name)` / `unlock_music(id)` / `unlock_movie(id)` | Gallery unlocks. |
| `get_save_dir()` | Full path to this pack's save folder. |

```gdscript
VNSave.save_game(story_runner.state, VNSave.AUTOSAVE_SLOT)
var ok: bool = VNSave.is_line_seen(chapter_id, line_id)
```

Saves are JSON at `user://saves/<namespace>/save_slot_<id>.json`, with a
matching `save_slot_<id>.png` thumbnail. Global progress lives in
`user://saves/<namespace>/global_data.json`. No signals on `VNSave`.

## VNSettings

Player-facing settings (display, audio, text), persisted to
`user://settings.json`.

| Member | What it does |
|---|---|
| `data: Dictionary` | The live settings tree (`display`, `audio`, `text`, `autosave`). Change it directly, then apply/save. |
| `apply_all_settings()` | Applies `data` to the running engine (window, audio buses, language) and emits `settings_changed`. |
| `save_settings()` | Writes `data` to `user://settings.json`. |
| `reset_to_defaults()` | Restores `default_data()`, applies and saves. |
| `set_text_speed_normalized(t)` / `get_text_speed_normalized()` | 0..1 slider mapped onto the real speed range. |
| `settings_changed` (signal) | Fires after `apply_all_settings()`. Open panels connect to it to react live. |

```gdscript
VNSettings.data["audio"]["music"] = 0.5
VNSettings.apply_all_settings()
VNSettings.save_settings()
```

## VNLocale

Thin wrapper over Godot's built-in `TranslationServer`.

| Member | What it does |
|---|---|
| `set_language(code)` | Sets the locale, applies a per-language theme override if one is registered, emits `locale_changed`. |
| `get_language()` | Returns `TranslationServer.get_locale()`. |
| `locale_themes: Dictionary` | Language code to `Theme`, empty by default (no override until you add one). |
| `locale_changed(code)` (signal) | Fires from `set_language()`. |

```gdscript
VNLocale.set_language("tr")
```

## VNPaths (static, not an autoload)

Single source of truth for content file paths, all built from one
project setting.

| Function | Returns |
|---|---|
| `content_root()` | The content root folder, always ending in `/`. |
| `manifest()` | `<root>config/game.tres` |
| `asset_map()` | `<root>config/asset_map/_asset_map.tres` |
| `cast_file()` | `<root>config/characters/_characters.tres` |
| `scenario_root()` | `<root>scenario/` |
| `locale_dir()` / `dialog_csv()` / `line_ids()` | `<root>locale/`, its `dialog.csv`, its `line_ids.txt` |

## VNLog (static, not an autoload)

`VNLog.debug/info/warn/error(tag, message)`. Every engine log line goes
through this, formatted as `[Tag] message`. `warn`/`error` route to
Godot's debugger via `push_warning`/`push_error`. `debug` only prints in a
debug build, and only when the `vn_engine/debug/verbose_log` setting is on.

## Project settings

Godot does not show tooltip text for custom project settings, so this
table is the reference for what each one does.

| Key | Default | Used by |
|---|---|---|
| `vn_engine/content/root` | `res://game/` | `VNPaths`, points the whole engine at a content folder. |
| `vn_engine/tools/report_dir` | `res://vn_engine_reports/` | `tools/asset_linter.gd`, where the lint report is written. |
| `vn_engine/debug/verbose_log` | `false` | `VNLog.debug()`, turns on debug-level logging. |

All three are registered by `plugin.gd` on `_enter_tree()`, with
`PROPERTY_HINT_DIR` on the two path settings, so they show up as folder
pickers in **Project Settings > VN Engine** (turn on Advanced Settings to
see them).

The lint report is a developer file written by an editor tool, so it
defaults to a folder inside the project (`res://`) where you can see it in
the FileSystem dock. Add that folder to `.gitignore` if you don't want the
report in git.
