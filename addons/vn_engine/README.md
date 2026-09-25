# VN Engine

A visual novel engine for Godot 4.4, packaged as an editor plugin.
A game built on it is just data: `.tres` resources plus plain text
scenario files. No engine code changes needed to make a new game.
Two or more games can share the same copy of the engine.

## Folder map

```
addons/vn_engine/
  defs/       Resource classes that define the data schema (GameManifest, ChapterDef, FlagList, ...)
  core/       story/ (parser, linter, expressions), commands/ (@commands), runtime/ (StoryRunner, StoryState, rollback), plus VNLog, VNPaths, VNText
  flow/       The app shell: VNMain, VNGame (autoload), screen and overlay stacks, transitions, endings
  globals/    The other three autoloads: VNSave, VNSettings, VNLocale
  screens/    One screen per route: title, stage, opening, credits, extras, chapter select, diagnostics, loading
  ui/         In-scene UI: dialog box, choices, character sprites, card overlay, dev overlay, panels
  systems/    Scene managers a chapter uses: background, audio, video, camera, asset resolver
  shaders/    Transition and locked-gallery shaders
  themes/     The default UI theme
  tools/      Editor-only scripts: asset linter, line id tool, locale CSV tool
  sample/     A tiny working game, see sample/HOW_TO_RUN.md
  docs/       Reference docs, see Documentation below
```

## Getting started

1. Copy `addons/vn_engine/` into your project and enable the plugin in
   **Project Settings > Plugins**.
2. Set the main scene to `addons/vn_engine/flow/scenes/vn_main.tscn` and
   add the autoloads `VNSave`, `VNSettings`, `VNLocale`, `VNGame` (see
   their paths under `globals/` and `flow/`).
3. Set **Project Settings > VN Engine > Content > Root** (turn on
   Advanced Settings to see it) to `res://addons/vn_engine/sample/` and
   press Play. This runs the built in sample, the smallest game the
   engine can run: one chapter of plain text, no images or sound.
4. Read `sample/HOW_TO_RUN.md` for how to copy it as the start of your own
   game. A game is a folder with a `config/` tree of `.tres` resources
   and a `scenario/<chapter_id>/` folder per chapter. `game/` and
   `game2/` in the repository root are two bigger example games, kept
   as test material rather than the thing you start from.
5. Switch between games any time by changing the content root setting.
   Same engine, different folder, no code change.

## Scenario format

Scenario files are plain text. A short example:

```
# start
Narrator: It was a quiet afternoon.

# meet
Hana: Oh, it's you. I didn't expect to see you here.
- Say hello. -> hello
- Stay quiet. -> quiet
```

A node starts with a `#` header. A `speaker: text` line is dialogue, a
`-` line is a choice, an `@` line is a scenario command. Full syntax and
the full scenario commands list are in [`docs/SCENARIO.md`](docs/SCENARIO.md)
and [`docs/COMMANDS.md`](docs/COMMANDS.md).

## Autoloads

- **VNGame** owns the game manifest and chapter and ending flow: which
  chapter comes next, which ending plays, opening and closing screens.
- **VNSave** reads and writes save files, quicksave and autosave slots,
  and global data such as unlocked gallery items and endings seen.
- **VNSettings** holds player settings: display, audio, text speed,
  language, and applies them.
- **VNLocale** is a thin wrapper over Godot's TranslationServer, for
  switching the active language.

See [`docs/GLOBALS.md`](docs/GLOBALS.md) for the full reference.

## What is supported

- Chapters with linear or branching flow, chosen by flag conditions
- Flags and counters, per playthrough or global, with save and rollback
- Choices, with an optional countdown timer and per-choice conditions
- Save and load slots, autosave on chapter entry, quicksave and quickload
- Rollback and forward through dialogue history, plus a backlog panel
- A gallery for CG art, music, movies and endings, with lockable entries
- Credits screens, opening and ending sequences, video playback
- Localization through a `dialog.csv` file, imported as a Translation (experimental, see below)
- Built in editor lint tools: asset linter, line id tool, locale CSV tool

## Documentation

- [`docs/SCENARIO.md`](docs/SCENARIO.md): scenario file syntax, nodes, dialogue, choices, scenario commands.
- [`docs/COMMANDS.md`](docs/COMMANDS.md): scenario commands reference, every `@command` with its arguments.
- [`docs/CONFIG.md`](docs/CONFIG.md): the `.tres` config schema, manifest, chapters, flags.
- [`docs/FLOW.md`](docs/FLOW.md): how the engine boots, moves between screens, and ends a chapter.
- [`docs/TOOLS.md`](docs/TOOLS.md): the editor tools, what each one does and how to run it.
- [`docs/GLOBALS.md`](docs/GLOBALS.md): the four autoloads and the two static helper classes.

## Text sizes and theme

All UI uses `themes/vn_default.tres`. Sizes are set for a 1920x1080 design
space (the window scales it, 1280x720 shows everything at 2/3). Body text
and buttons use the theme default size (36). Other sizes are theme type
variations, so a scene picks one with `theme_type_variation`:

| Variation | Size | Used for |
|---|---|---|
| `VNTitleLabel` | 72 | Big centered titles, chapter cards |
| `VNHeadingLabel` | 52 | Screen and panel titles |
| `VNSubheadingLabel` | 40 | Subtitles, credits section names |
| `VNSmallLabel` / `VNSmallButton` | 28 | Meta info, quick menu buttons |
| `VNTinyLabel` | 22 | Dev and debug text only |

To make all text bigger or smaller, change these numbers in the theme,
no scene needs to be edited.

## Design decisions

Some choices here are different from other VN engines, so here is why.

**Why write an engine in Godot and not use Ren'Py?**
Ren'Py is great and it is much bigger than this engine. I'm not trying to
compete with it. I wanted a small engine with only the features I need,
and I wanted to write it myself to learn how a VN engine works inside.
Also I want to mix VN parts with other mechanics later, for example
dialogues inside an RPG. In Godot I can use everything the engine already
has for that.

**Why `.tres` files for config and not JSON?**
Godot already has a good editor for resources: the Inspector. With `.tres`
files you can change the game data without writing code, and you get
types, enums and dropdowns for free. Godot also keeps the references
when you move a file. JSON would need its own editor and its own
validation. Every chapter, ending, flag and character has its own small
file, so things are easy to find and git diffs stay small.

**Why plain text scenario files?**
Writing dialogue is faster in a text editor than in a node graph, and
text files work well with git. A visual dialogue editor can be made
later, but it will be a separate project.

**Why a custom condition language and not Godot's `Expression`?**
Conditions (`if`, `disabled_if`, `@jump_if`) are handled by
`ExpressionEvaluator`, a small language written for this engine. I want
the control to stay on the engine side, and a small language fits this
engine better:

- It only knows flags, numbers, strings, `and`/`or`/`not` and comparisons.
  A scenario file can't call any Godot method, so a bad line in a script
  can't reach into the engine.
- The grammar is small, so the linter can check every condition before
  the game runs. Unknown flag names and broken expressions show up in the
  editor, not in the middle of a playthrough.
- Errors point to the scenario line, which is easier to read than a
  Godot error.

**Why one engine and many games?**
The engine never reads a fixed game path. Everything goes through
`vn_engine/content/root`, so `game/`, `game2/` and `sample/` run on the
same engine code. If something only works for one game, it belongs in
that game's data, not in the engine.

## Experimental and future ideas

Experimental, it works but it's not tested enough:

- **Localization.** The line id tool, the locale CSV tool and the language
  page in settings. I only tested with English, no real translation was
  made yet.

Not in the engine yet, can be implemented in the future:

- Screen filters (grayscale, sepia, vignette) with a `@filter` command.
- Voice lines per language. For now only text translation is supported,
  voice files don't have a language folder.
- Save file versioning. Until 1.0 the save format can change and old
  saves may not load, so there is no migration code.
- A visual dialogue editor, as a separate project.

## Current status and known limitations

The engine is at version 0.6, an early release. Before I call it 1.0 I
want to check the points below. None of them are known bugs, they are
just things I haven't verified yet:

- **No stress test yet.** I haven't run it with a long scenario and a lot
  of assets, music tracks and videos, so I don't know yet if performance
  needs work at that scale.
- **Caching, preloading and chunked loading may need more work.** The
  current chapter preloader is a first step, not a finished system.
- **Only tested by me playing it.** Real players do things I haven't
  tried: button mashing, odd input orders, alt-tabbing during a video,
  and so on.
- **Godot specific edge cases aren't fully checked.** Behavior across
  platforms and export targets, window/resolution changes, video codec
  support (Godot only plays Ogg Theora), and web export are all
  unverified.

These are engineering details, and waiting for all of them would mean
never releasing. The plan is to keep improving them after release. Bug
reports and feedback are welcome.

## License

MIT. See [`../../LICENSE.md`](../../LICENSE.md).
