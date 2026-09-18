# Writing config files

A game's data (chapters, flags, characters, screens, ...) lives as `.tres`
resource files under a "content root" folder, default `res://game/`. You can
point the engine at a different folder in Project Settings > General >
Vn Engine > Content > Root (see `addons/vn_engine/core/vn_paths.gd`).

Every field on these config resources has a short description already.
Hover the property name in the Godot Inspector to read it, that covers
most simple questions without needing this doc.

## Folder layout

```
<content root>/
  config/
    game.tres                GameManifest, the entry point
    boot/_boot.tres           BootDef (index)
    boot/NN_<name>.tres       BootScreenDef, one per boot step
    chapters/<id>.tres        ChapterDef
    endings/<id>.tres         EndingDef
    flags/_flags.tres         FlagList (index)
    flags/<id>.tres           FlagDef
    credits/_credits.tres     CreditsDef (index)
    credits/NN_<role>.tres    CreditsSection
    characters/_characters.tres  Cast (index)
    characters/<id>.tres      CastMember
    asset_map/_asset_map.tres    AssetMap (index)
    asset_map/<kind>.tres     AssetMapEntry
    screens/title.tres        TitleScreenDef
    screens/extras.tres       ExtrasDef
    screens/ui.tres           UiDef
  scenario/<chapter_id>/*.txt   scenario files, see SCENARIO.md
```

## The index file rule

Some folders (`boot/`, `flags/`, `credits/`, `characters/`, `asset_map/`)
hold one `_<folder>.tres` index file plus one small file per entry. The
index only stores an ordered list of `ExtResource(...)` links, it doesn't
embed the entries. To edit an entry, open its own small file directly.
Adding a new entry means: create the small `.tres` file, then add it to the
index's array field by hand, it is not picked up automatically.

`game.tres` (`GameManifest`) works the same way for `chapters`, `endings`
and the `screens/*` files, but it stays at the config root instead of using
its own `_game.tres`, since it's already the single entry point
(`VNPaths.manifest()`).

## Config resources

### GameManifest

File: `config/game.tres`. The root resource. An index plus identity/flow
fields, engine reads this file first (`VNPaths.manifest()`).

| Field | Group | Meaning |
|---|---|---|
| `game_id` | Identity | Unique id for this game, separates save files between games. |
| `title_key` | Identity | Translation key. |
| `version` | Identity | e.g. `"0.1.0"`. |
| `first_chapter` | Flow | `ChapterDef.id` a new game starts on. |
| `default_ending` | Flow | Fallback ending when the story ends without `@end`. |
| `chapters` | Flow | `Array[ChapterDef]`. |
| `endings` | Flow | `Array[EndingDef]`. |
| `boot` | Content | `BootDef`. `null` = no boot sequence. |
| `flags` | Content | `FlagList`. |
| `credits` | Content | `CreditsDef`. |
| `title` | Screens | `TitleScreenDef`. |
| `extras` | Screens | `ExtrasDef`. `null` = default behaviour. |
| `ui` | Screens | `UiDef`. `null` = default behaviour. |
| `locales` | Localization | `PackedStringArray`, e.g. `["en", "tr"]`. |

### BootDef

File: `config/boot/_boot.tres` (index). Boot sequence played before the
title screen: an ordered list, `boot_screens: Array[BootScreenDef]`. Each
entry is one screen (a studio logo, a content/age warning, a "fictional
characters" disclaimer, a trailer, ...), played in the order they're
listed. An empty list goes straight to the title screen.

| Field | Meaning |
|---|---|
| `boot_screens` | `Array[BootScreenDef]`, played in order. Empty = straight to title. |

### BootScreenDef

File: `config/boot/NN_<name>.tres`, one file per step. `NN` is a two-digit
prefix so the index file's order matches the file order in the FileSystem
dock. Either `image_path` or `movie_path`, not both, `movie_path` wins if
both are set.

| Field | Meaning |
|---|---|
| `enabled` | Set `false` to drop this one step without deleting it. |
| `note` | Free text for you (e.g. "epilepsy warning"). Never shown in game. |
| `image_path` | `.png`/`.jpg`/`.jpeg`/`.webp`/`.svg`. |
| `movie_path` | `.ogv`. Wins over `image_path` when both are set. |
| `duration` | Image screens only, time on screen including fades. |
| `fade_time` | Image screens only. |
| `wait_for_input` | Image screens only. Waits for a click/key instead of `duration`. Use this for a warning screen the player must acknowledge. |
| `background_color` | Backdrop color behind the image. |
| `skippable` | A click/key skips this screen. Ignored when `wait_for_input` is on. |

### ChapterDef

File: `config/chapters/<id>.tres`. `id` must equal the folder name of
`script_path` (`res://<content>/scenario/<folder>/...`). A mismatch breaks
seen-line/branch/ending matching and the save's chapter id silently.

| Field | Group | Meaning |
|---|---|---|
| `id` | Identity | Must equal `script_path`'s parent folder name. Prefixes generated line ids. |
| `title_key` | Identity | Translation key for the chapter title. |
| `subtitle_key` | Identity | Translation key for the subtitle. Empty = no subtitle. |
| `script_path` | Identity | Path to this chapter's scenario file. |
| `intro_style` | Intro | `"none"`, `"card"`, or `"eyecatch"`. |
| `intro_background` | Intro | bg id, used by `"card"`. |
| `intro_duration` | Intro | Seconds. |
| `bgm` | Intro | Plays on chapter start. `""` leaves the current music unchanged. |
| `autosave_on_enter` | Flow | |
| `next_chapter` | Flow | Plain linear continuation. |
| `branches` | Flow | `Array[ChapterBranch]`, checked before `next_chapter`. |
| `unlock_condition` | Flow | `""` = always unlocked, for the chapter-select screen. |

### ChapterBranch

Not its own file, kept inline in `ChapterDef.branches`.

| Field | Meaning |
|---|---|
| `condition` | Boolean expression checked against flags, e.g. `"affection_hana >= 7 and not saw_bad_ending"`. True means take this branch. |
| `chapter_id` | Chapter to go to if `condition` is true. |

### EndingDef

File: `config/endings/<id>.tres`. When `@end` runs with no argument,
`GameManifest.endings` is scanned in order for the first entry whose
`condition` is true; if none match, `GameManifest.default_ending` is used.
`@end <id>` picks an ending directly and ignores `condition`.

| Field | Group | Meaning |
|---|---|---|
| `id` | Identity | Used by `@end <id>`. |
| `title_key` | Identity | Translation key for the ending title. |
| `rank` | Identity | `"true"`, `"good"`, `"normal"`, `"bad"`, `"joke"`. |
| `number` | Identity | Shown in the gallery, like "END 03". |
| `is_secret` | Identity | Shows as "???" in extras until seen. |
| `condition` | Selection | Checked when `@end` is called with no argument. |
| `cg` | Presentation | Backdrop CG id for the ending card. |
| `bgm` | Presentation | Music played during the ending card. |
| `card_duration` | Presentation | Seconds. |
| `credits_variant` | Presentation | `""` = default credits, `"none"` = skip credits. |
| `ed_movie` | Presentation | Ending theme video. |
| `unlocks` | Unlocks | `PackedStringArray` of global flags unlocked when this ending plays. |

### FlagList

File: `config/flags/_flags.tres` (index).

| Field | Meaning |
|---|---|
| `flags` | `Array[FlagDef]`. |

### FlagDef

File: `config/flags/<id>.tres`. One flag/counter.

| Field | Meaning |
|---|---|
| `id` | Flag id, e.g. `"affection_hana"`. Should be lowercase, the linter warns otherwise. |
| `type` | `"bool"`, `"int"`, or `"string"`. |
| `default_value` | Text form, converted to the real type by `FlagList.coerce()`. |
| `scope` | `"playthrough"` (in the save, part of rollback, reset on new game) or `"global"` (persistent across playthroughs). |
| `min_value` / `max_value` | Clamp range for `int` type. |
| `debug_name` | Shown in the dev overlay (F3) instead of the raw id, when set. |

### Cast

File: `config/characters/_characters.tres` (index).

| Field | Meaning |
|---|---|
| `characters` | `Array[CastMember]`. |

### CastMember

File: `config/characters/<id>.tres`.

| Field | Group | Meaning |
|---|---|---|
| `id` | Identity | Used in scenario files, e.g. `"hana"`. Must be unique. |
| `display_name` | Identity | Shown in the dialog box. |
| `is_narrator` | Identity | Skips name display, counts as narration. |
| `name_color` | Identity | Color for this character's name. |
| `default_outfit` | Default sprite | Used when a line doesn't set one. |
| `default_pose` | Default sprite | e.g. `"armscrossed"`, `"base"`. |
| `default_expression` | Default sprite | Facial expression only. |
| `default_shot` | Default sprite | `"far"`, `"mid"`, `"close"`. |
| `sprite_scale` | Default sprite | Size multiplier for the sprite box (760x1000 at 1.0). Use it if the art is drawn bigger or smaller. |

### AssetMap

File: `config/asset_map/_asset_map.tres` (index).

| Field | Meaning |
|---|---|
| `entries` | `Array[AssetMapEntry]`, one per asset kind. |

### AssetMapEntry

File: `config/asset_map/<kind>.tres`.

| Field | Meaning |
|---|---|
| `kind` | `"background"`, `"character"`, `"cg"`, `"music"`, `"sfx"`, `"voice"`, or `"movie"`. |
| `root` | Folder this kind's files live in, e.g. `"res://game/backgrounds/"`. |
| `extensions` | Extensions to try in order, e.g. `[".png", ".webp"]`. First one that exists wins. |

### AudioChannel

Not part of `config/`. Set on the `AudioManager` node inside
`addons/vn_engine/systems/scenes/audio_system.tscn`, as its exported
`channels: Array[AudioChannel]`. One entry per command name (`"music"`,
`"sfx"`, ...).

| Field | Meaning |
|---|---|
| `command_name` | Command name in scripts, e.g. `"music"` or `"sfx"`. |
| `use_fade` | If true, volume changes fade instead of cutting instantly. |
| `bus_name` | Godot audio bus. Falls back to `"Master"` if the bus doesn't exist. |
| `base_volume_db` | Base volume in dB. Fades target this. |

### CreditsDef

File: `config/credits/_credits.tres` (index).

| Field | Group | Meaning |
|---|---|---|
| `variant` | Content | `""` = default. |
| `sections` | Content | `Array[CreditsSection]`. |
| `scroll_speed` | Presentation | px/sec. |
| `bgm` | Presentation | Music played during credits. |
| `background` | Presentation | Background asset behind the credits. `""` = none. |
| `movie` | Presentation | If set, plays instead of scrolling. |
| `allow_skip` | Presentation | If true, the player can skip. |
| `end_logo` | Presentation | Logo shown after credits finish. `""` = none. |

### CreditsSection

File: `config/credits/NN_<role>.tres`. `NN` sets roll order.

| Field | Meaning |
|---|---|
| `role_key` | Translation key for the role label, e.g. `"credits.role.director"`. |
| `names` | `PackedStringArray`, proper names, not translated. |

### ExtrasDef

File: `config/screens/extras.tres`. `null` on `GameManifest.extras` means
"all rooms on, auto-listed from the asset map, '?' placeholders".

| Field | Group | Meaning |
|---|---|---|
| `show_gallery` / `show_music` / `show_endings` / `show_movies` | Rooms | Toggle each room. |
| `locked_style` | Locked entries | `"placeholder"`, `"blur"`, or `"image"`. |
| `locked_text` | Locked entries | Text on a locked gallery card. |
| `locked_name_text` | Locked entries | Name shown for a locked music/movie/ending entry. |
| `secret_ending_text` | Locked entries | Row text for an unseen `EndingDef.is_secret`. |
| `locked_image` | Locked entries | Used when `locked_style == "image"`. |
| `blur_strength` | Locked entries | Used when `locked_style == "blur"`. |
| `gallery_items` / `music_items` / `movie_items` | Entries | `Array[ExtrasItem]`. Empty = every id of that kind from the asset map. |

### ExtrasItem

Not its own file, kept inline in `ExtrasDef`'s arrays.

| Field | Meaning |
|---|---|
| `id` | Asset id, e.g. `"cg_cottage_fire_01"`. |
| `title_key` | Display name, translation key or plain text. Empty = show the id. |
| `thumbnail` | Optional card image instead of the asset itself. |
| `hidden_until_unlocked` | Not listed at all while locked. |
| `locked_style` | `"default"` (use `ExtrasDef.locked_style`), `"placeholder"`, `"blur"`, `"image"`. |
| `locked_text` | Overrides `ExtrasDef.locked_text` for this one entry. `""` = use default. |

### TitleScreenDef

File: `config/screens/title.tres`.

| Field | Group | Meaning |
|---|---|---|
| `background` | Normal | Background asset id. |
| `bgm` | Normal | |
| `logo` | Normal | `res://` path or a background/cg asset id. `""` = no logo. |
| `menu_alignment` | Normal | `"left"`, `"center"`, `"right"`. |
| `cleared_background` | Cleared | Used once the game has been cleared. |
| `cleared_bgm` | Cleared | `""` keeps using `bgm`. |
| `show_extras_when` | Menu visibility | `""` (always), `"cleared_once"`, `"never"`, or a global-flag expression. |
| `show_chapter_select_when` | Menu visibility | Same values as `show_extras_when`. |
| `chapter_select_in_debug` | Menu visibility | Debug builds always show Chapter Select, for testing. |

### UiDef

File: `config/screens/ui.tres`. `null` on `GameManifest.ui` means these
defaults.

| Field | Group | Meaning |
|---|---|---|
| `overlay_backdrop_color` | Overlays | Backdrop behind settings/load/log panels. |
| `confirm_quit` | Confirmations | |
| `confirm_overwrite_save` | Confirmations | |
| `dialog_use_character_colors` | Dialog box | Speaker name uses `CastMember.name_color`. |
| `dialog_name_align` | Dialog box | `"left"` or `"center"`. |
| `loading_mode` | Loading screen | `"always"`, `"when_slow"`, `"never"`. |
| `loading_min_duration` | Loading screen | Minimum time the loading screen stays up. |
| `loading_show_chapter_title` | Loading screen | Skipped for chapters with `intro_style != "none"`. |
| `log_use_character_colors` | Log | Backlog speaker names use `CastMember.name_color`. |

