# VN Engine sample

The smallest content pack that runs on VN Engine. It lives inside the
plugin, so a copy of only `addons/vn_engine/` still has a working example.
No images, no audio, no video: one chapter of plain text with a speaker,
a choice, a flag, and an ending.

## Run it

Open **Project Settings > General > VN Engine > Content > Root**
(turn on Advanced Settings to see it) and set it to:

```
res://addons/vn_engine/sample/
```

Then press Play.

## Start your own game from it

1. Copy this whole `sample/` folder somewhere outside `addons/vn_engine/`,
   for example to `res://my_game/`.
2. Set `vn_engine/content/root` to `res://my_game/`.
3. Rename `config/chapters/chapter1.tres` and the `scenario/chapter1/`
   folder together, keeping the chapter's `id` equal to the scenario
   folder name.
4. Edit `config/game.tres` for your `game_id`, `first_chapter`, and
   `default_ending`, then add characters, flags, chapters and endings the
   same way this sample does.

See [`../README.md`](../README.md) for the full engine guide and
[`../docs/COMMANDS.md`](../docs/COMMANDS.md) for every `@command`.
