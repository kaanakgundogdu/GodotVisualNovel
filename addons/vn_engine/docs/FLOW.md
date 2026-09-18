# Engine Flow

How the engine moves from boot to a dialogue line on screen, and back.

## Boot sequence

The main scene is `flow/scenes/vn_main.tscn`. Four autoloads load first,
in this order: `VNSave`, `VNSettings`, `VNLocale`, `VNGame`. `VNGame`
loads the shared asset map and the manifest (`config/game.tres`) before
the main scene runs.

The main scene then, in order:

1. Builds the screen stack and overlay stack.
2. Loads the audio system as a persistent node, so music keeps playing
   across screen and chapter transitions.
3. Builds the debug overlay, in debug builds only.
4. Picks the first screen: the boot sequence if the manifest has one,
   otherwise the title screen directly.

## Boot screens

The boot sequence is a `BootDef` with a `boot_screens` array (studio
logo, content warning, trailer, ...). Each enabled entry plays in order,
one at a time: movie first if a movie is set, otherwise the image with a
fade. A step can be skippable or wait for input. Once the queue is
empty, or if there's no boot sequence at all, the engine goes straight
to the title screen.

## Title

The title screen reads `GameManifest.title` for its background, music,
logo, and menu alignment, and shows buttons for New Game, Load Game,
Settings, Extras/Gallery, and Chapter Select (each conditionally, per
`TitleScreenDef`). New Game checks that the manifest is loaded and
`first_chapter` is set, then jumps into that chapter.

## Screen stack vs overlay stack

Two separate layers. The **screen stack** holds one full screen at a
time (title, stage, opening, credits, extras, chapter select,
diagnostics, loading); switching screens always frees the old one and
builds a fresh scene. The **overlay stack** holds panels that stack on
top of the active screen (settings, load, gallery, log, confirm); the
screen underneath blurs while an overlay is open, and only the topmost
overlay gets input. Several overlays can be open at once.

## Chapter start and the loading screen

Starting a chapter looks up its `ChapterDef`, starts its BGM if one is
set, carries over flags and history from the chapter that was just
playing (if any), and then routes through a loading screen while the
chapter's assets preload, unless loading is turned off in `UiDef`.

The loading screen has two modes: `"when_slow"` only shows the bar if
loading is still running after the first frame, `"always"` shows
immediately and stays up for at least `min_duration`. The progress bar
tracks real loading progress, not a fake timer.

## From a scenario file to a line on screen

A scenario file is parsed into nodes, the linter runs automatically as
part of parsing, and each node's commands run before its dialogue line
shows or its choices are offered. Most commands run immediately; a
handful of flow commands (`jump`, `jump_if`, `call`, `return`, `scene`,
`end`, `goto_chapter`, `credits`) run only after the player advances
past the current line, so a single node can carry both a line of
dialogue and a jump.

## Chapter end and branching

When the story ends, the branch it takes depends on why it ended:

- **Explicit `@end`**: an explicit ending id wins if given, otherwise
  the first `EndingDef` in the manifest whose condition matches the
  current flags, otherwise the manifest's `default_ending`.
- **Ran off the end of the script**: the chapter's `branches` are
  checked in order (first matching condition wins), then its
  `next_chapter`, then `default_ending`.
- **Runaway guard** (256 logic nodes in a row with no dialogue): the
  engine returns to the title screen without picking an ending.

Reaching an ending marks it seen, increments the clear count, applies
its `unlocks` as global flags, plays the ending card (movie, then CG,
then a title-only card, whichever the ending has), and then either
plays credits or returns to the title screen depending on the ending's
`credits_variant`.

## Save timing and rollback

**Autosave** runs once, right after a chapter starts fresh (never on
load), if `ChapterDef.autosave_on_enter` and the autosave setting are
both on.

**Rollback** keeps a snapshot of story state every time a node's
dialogue is about to show. Rolling back or forward moves a cursor over
those snapshots and restores state from them, commands are never
re-run, only the state, so visuals and audio catch up to match the
restored snapshot rather than replaying whatever produced it.

## Adding a new screen or command

- **New `@command`**: add `core/commands/cmd_<name>.gd` extending
  `VNCommand`, return `"<name>"` from `command_name()`, then add
  `"<name>"` to `CommandRegistry.NAMES`.
- **New screen**: build a scene and script extending `VNScreen`
  (`flow/vn_screen.gd`), override `screen_id()`/`enter()`/etc., and add
  an entry to `ScreenStack.SCREEN_PATHS`.
- **New overlay panel**: same idea, add an entry to
  `OverlayStack.OVERLAY_PATHS` instead.
- **Changing what happens after a chapter ends**: that logic lives in
  `VNGame.on_story_ended()` in `flow/vn_game.gd`.
