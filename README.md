# Visual Novel Engine for Godot

This is my Visual Novel Project. This visual novel engine built in Godot 4.4 addon, with sample and example games. 
It shows different content and gameplay mechanics.


## Devlog

You can read Devlogs in my blog:


https://kaanakgundogdu.github.io/blog/VisualNovelGodot/devlog1.html


https://kaanakgundogdu.github.io/blog/VisualNovelGodot/devlog2.html


### First version v0.1.0

![First version](/readme_files/videos_gifs/vnlearn.gif)

### Second version v0.2.0

![Second version](/readme_files/videos_gifs/vn_last_ver.gif)


## Repository layout

- `addons/vn_engine/`: the engine itself.
- `addons/vn_engine/sample_game/`: a tiny content pack that ships inside the engine, with no images or sound, the smallest thing that runs.
- `game/`: example game (default content root)
- `game2/`: second small example proving the engine is content-independent
- `assets/`: shared art and audio used by the examples

## Features

- Complete visual novel engine as a reusable addon (drop this into your Godot 4.4 project)
- Boot splash sequences (studio publisher logos in image or video format, skippable)
- Title screen with customizable background, music, logo, and cleare variant
- Chapter-based story flow with auto-save and auto-load save slots
- Quicksave/quickload with dedicated hotkeys (F5/F9)
- Multipage settings (display, audio, text, language) with custom page support via `SettingsPanel.register_page()`
- Full extras system: CG gallery, music room, endings list, movie room with locked entry styles
- Endings with optional ending movies and credits screen (scrolling or video)
- Backlog (dialog history) with speaker colors and voice replay
- Auto-read, skip, and rollback/forward through history
- Built-in diagnostics screen and F3 debug overlay (debug builds only)
- Content agnostic: You can switch between games by changing `vn_engine/content/root` in Project Settings, same engine code, different game data

The engine is at version 0.6, an early release, tested only by me so far.

## Quick start

1. Open the project in Godot 4.4
2. Press Play to run the default example game
3. To run the second example, set Project Settings → `vn_engine/content/root` to `res://game2/` (dont forget to enable Advanced Settings in)
4. To see the engine's own minimal sample (no art, no audio), set the same setting to `res://addons/vn_engine/sample_game/`

## License

MIT. See LICENSE.md.
