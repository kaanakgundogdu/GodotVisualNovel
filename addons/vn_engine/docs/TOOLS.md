# Editor Tools

Editor-only scripts under `tools/`. Two kinds: scripts you run by hand
(`EditorScript`), and a linter that runs on its own every time a scenario
file gets parsed.

## How to run an EditorScript tool

There is no `godot` CLI command for these. Run them from inside the editor:

1. Open the script in the FileSystem dock (double-click it).
2. Make sure its tab is the active one in the script editor.
3. **File > Run** (or `Ctrl+Shift+X`).
4. Read the result in the **Output** panel (bottom of the editor).

## Asset Linter (`tools/asset_linter.gd`)

Scans the whole content root (assets, scenario files, `GameManifest`) and
writes a markdown report. Read-only, it never edits, deletes or moves a
file.

**What it's for:** catches broken references before you hit them in play
mode, mismatched CG/background folders, orphaned art nobody uses,
manifest chapters that point nowhere, unknown commands typed by hand. Run
it before a build or after a big content pass, not every time you tweak a
line.

**Output:** `asset_lint_report.md`, written under the
`vn_engine/tools/report_dir` project setting (default
`res://vn_engine_reports/`). The report lists every rule's findings, each
tagged `[ERROR]`, `[WARNING]` or `[INFO]`, plus a summary count at the top.
It's a developer file written by an editor tool, so it defaults to a
folder inside the project where you can see it in the FileSystem dock.
Add that folder to `.gitignore` if you don't want the report in git.

### The 12 rules

| # | Rule | Checks |
|---|---|---|
| 1 | Naming violations | A file's name does not match the naming pattern for its asset kind (backgrounds, cg, character, music, sfx, ui, movie). |
| 2 | Orphan assets | A file exists on disk but no scenario line references it. |
| 3 | Missing assets | A background/music/sfx/movie name used in a scenario does not exist on disk. |
| 4 | CG/BG mixup | A file named with a `cg_` prefix sits outside `cg/`, or a `bg_` file sits outside `backgrounds/`. |
| 5 | Sprite matrix gaps | An expression exists for a character in one outfit/pose but is missing from that character's default outfit/pose/shot combination. |
| 6 | Unidentified voice lines | A voice file's name matches no id in `line_ids.txt`. |
| 7 | Dead translation keys | A key in `dialog.csv` no longer corresponds to any generated line id. |
| 8 | CG chapter folder layout | A CG file sits directly under `cg/`, or its subfolder matches no `ChapterDef.id`. |
| 9 | Manifest references | A chapter's `script_path` is missing on disk, or `next_chapter`/branch targets/`default_ending` point at an id that does not exist. |
| 10 | Duplicate ids | Two chapters or two endings share the same id (case-insensitive). |
| 11 | Unknown commands | A `@command` in a scenario file is not registered in `CommandRegistry`. |
| 12 | Missing sprites | A `@show` line's character/outfit/pose/expression/shot combination resolves to no file on disk. |

## Line ID Tool (`tools/line_id_tool.gd`)

Parses every scenario `.txt` file under the content root and writes
`locale/line_ids.txt`, one line id per row, sorted.

**What it's for:** this file is the source of truth for translation and
voice matching. Run it whenever you add, remove or rename dialogue lines,
before running the Locale CSV Tool. It also warns (in the Output panel) if
a line id that existed before is gone now, which usually means a label got
renamed and the old translation/voice line is now orphaned.

## Locale CSV Tool (`tools/locale_csv_tool.gd`)

Parses scenario files again and writes `locale/dialog.csv`: one row per
line id plus one `char.<id>.name` row per non-narrator character.

**What it's for:** builds (and updates) the translation file you import
into Godot. It never overwrites an existing translation: a key already in
the CSV keeps its row untouched, a new key gets added with the source
text, and a key that is no longer generated gets prefixed `#OLD#` instead
of deleted. After running it, import `dialog.csv` in the editor's Import
panel as **Import As: Translation**.

## ScenarioLinter, a different kind of check

`core/story/scenario_linter.gd` is not run by hand. It runs automatically
inside `ScenarioParser.parse_file()`, every time a scenario file is parsed
(new chapter, load, rollback). It checks things the Asset Linter can't:
unresolved jump/choice targets, unreachable nodes, bad command arguments,
undefined flags. Results become `ParseDiagnostic` entries on the parsed
`StoryScript` and show up on the in-game diagnostics screen when they
include an `ERROR`. You never launch this one, just fix what it flags
when you see the diagnostics screen or a warning in the Output panel.

## When to run which

| Situation | Tool |
|---|---|
| Added/renamed/removed dialogue lines | Line ID Tool, then Locale CSV Tool |
| Added or moved art/audio/video files | Asset Linter |
| Before a build, or after a big content pass | Asset Linter |
| A dialogue line looks wrong or crashes at parse time | Nothing to run, read the diagnostics screen (ScenarioLinter already ran) |
