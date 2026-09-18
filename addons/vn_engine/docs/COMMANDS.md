# Scenario commands

The `@` lines in a scenario file (`@bg`, `@show`, `@jump`, `@flag`, and so
on) are the scenario language itself, the way you stage a scene: set
backgrounds and music, move characters, jump between nodes, write flags.
They run as part of normal story playback, not as debug commands.

To add your own command, create `core/commands/cmd_<name>.gd` extending
`VNCommand`, return `"<name>"` from `command_name()`, and add `"<name>"`
to `CommandRegistry.NAMES`.

## Commands

**Staging:** [`@bg`](#bg), [`@cg`](#cg), [`@cg_hide`](#cg_hide), [`@show`](#show), [`@hide`](#hide), [`@leave`](#leave), [`@move`](#move), [`@shake`](#shake), [`@transition`](#transition), [`@window`](#window)
**Audio / video:** [`@music`](#music), [`@bgm_stop`](#bgm_stop), [`@sfx`](#sfx), [`@voice`](#voice), [`@movie`](#movie)
**Flow and state:** [`@set_var`](#set_var), [`@flag`](#flag), [`@jump`](#jump), [`@jump_if`](#jump_if), [`@call`](#call), [`@return`](#return), [`@scene`](#scene), [`@wait`](#wait), [`@end`](#end), [`@goto_chapter`](#goto_chapter), [`@credits`](#credits), [`@choice_timer`](#choice_timer)
**Cards:** [`@chapter_title`](#chapter_title), [`@eyecatch`](#eyecatch), [`@datecard`](#datecard)

## Staging

### `@bg`

```
@bg <name> [with <transition>] [<duration>]
```

Changes the background. `<name>` has no spaces (it can contain `/`), so
it's a single token. This does not unlock anything in the CG gallery,
that's `@cg`'s job.

### `@cg`

```
@cg <cg_id> [with <transition>] [<duration>]
```

Shows a full-screen CG. Unlike `@bg`, this also hides every active
character sprite, since a CG isn't meant to be shown together with
character sprites.

Example: `@cg cg_cottage_fire_01 with fade 0.8`

### `@cg_hide`

```
@cg_hide [with <transition>]
```

Returns to the background that was active before the last `@cg`.
Characters aren't brought back automatically, call `@show` again after
`@cg_hide` if you need them.

### `@show`

```
@show <id> [<expression>] [outfit=<x>] [pose=<x>] [shot=<x>] [at <position>] [with <transition>]
```

Shows a character sprite. Any field you leave out falls back to that
character's `CastMember` defaults (`default_expression`/`outfit`/`pose`/
`shot`).

Example: `@show hana happy outfit=uniform at left with fade`

### `@hide`

```
@hide <id> [with <transition>]
```

Hides a character sprite.

### `@leave`

```
@leave <id> [with <transition>]
```

Alias for `@hide`, same arguments, same effect.

### `@move`

```
@move <id> to <position> [over <duration>]
```

Moves a character sprite to a new position.

### `@shake`

```
@shake <preset>
```

Shakes the camera using the given preset name.

### `@transition`

```
@transition <kind> [<duration>]
```

Plays a full-screen cover + reveal transition. Known kinds are `fade`,
`wipe_*`, `shutter`, `flash`, `instant`, an unknown kind falls back to
`fade`. Blocking: the story waits until the transition finishes before
continuing.

### `@window`

```
@window <show|hide>
```

Shows or hides the dialog box instantly. Doesn't affect script flow.

## Audio / video

### `@music`

```
@music <id>
@music stop
```

Plays background music on the music channel and unlocks the track in the
music room. `stop` (or an empty id) clears it instead.

### `@bgm_stop`

```
@bgm_stop
```

Shorthand for `@music stop`.

### `@sfx`

```
@sfx <id>
@sfx stop
```

Plays a one-shot sound effect on the sfx channel. `stop` clears it
instead.

### `@voice`

```
@voice <id>
@voice stop
```

Plays a voice line on the voice channel. `stop` clears it instead.

### `@movie`

```
@movie <movie_id>
```

Plays a full-screen movie, blocking the story until it finishes.
Unlocks the movie in the gallery once it's done, whether the player
watched it through or skipped it.

## Flow and state

### `@set_var`

```
@set_var <name> <=|+=|-=|*=|/=> <value>
```

Untyped write to a variable. Does no clamping or type lookup, it just
stores whatever value you give it.

### `@flag`

```
@flag <id> <=|+=|-=|*=|/=> <value>
```

Typed write to a flag defined in `config/flags/`, clamped and coerced to
the flag's declared type (`bool`/`int`/`string`). Prefer this over
`@set_var` for anything backed by a `FlagDef`.

Flags with `scope == "global"` persist across playthroughs, in addition
to the current one.

### `@jump`

```
@jump <target>
```

Jumps to a target node.

### `@jump_if`

```
@jump_if <condition> -> <target>
@jump_if <variable> <op> <value> <target>
```

Jumps to `<target>` if `<condition>` is true. The first form is
preferred; the second, positional form still works but the linter flags
it, switch to the first form when you touch that line. The condition
goes through the full expression grammar (`and`/`or`/`not`, parentheses,
comparisons, `+`/`-`), see [`SCENARIO.md`](SCENARIO.md#conditions-expressions).

### `@call`

```
@call <target>
```

Jumps to `<target>` like `@jump`, but remembers where it was called from
so `@return` can come back to that point. Calls can nest; a runaway
recursion is stopped rather than allowed to loop forever.

### `@return`

```
@return
```

Returns to the node after the last `@call`. With no matching `@call` on
the stack, it ends the story instead.

### `@scene`

```
@scene <file> [<target>]
```

Switches to another scenario file, optionally jumping straight to
`<target>` in it. This is not Ren'Py's "scene" command, it only switches
which script file is playing, it doesn't clear the background or
characters. Hide or change what you need with `@hide`/`@bg` yourself.

### `@wait`

```
@wait <seconds>
```

Pauses the story for the given duration.

### `@end`

```
@end [<ending_id>]
```

Ends the story. With no `<ending_id>`, the engine picks the first
`EndingDef` in the manifest whose condition matches the current flags,
falling back to `GameManifest.default_ending`. See
[`CONFIG.md`](CONFIG.md#endingdef).

### `@goto_chapter`

```
@goto_chapter <chapter_id>
```

Switches to another chapter. Flags and other state carry over, only the
script changes.

### `@credits`

```
@credits [<variant>]
```

Jumps straight to the credits screen from inside a script, instead of
waiting for the automatic post-ending credits flow.

### `@choice_timer`

```
@choice_timer <seconds> [<default_index>]
```

Arms a countdown for the next choice screen only, it's not sticky and
has to be set again before each timed choice. If the timer runs out,
`<default_index>` is picked (0 if omitted). A choice reached by rolling
back doesn't replay the countdown, so the player isn't put under the
same time pressure twice.

## Cards

### `@chapter_title`

```
@chapter_title [<"title"> ["<subtitle>"] [<duration>]]
```

Opens the title card overlay, blocking. With no arguments, it reads the
current chapter's `ChapterDef` (`title_key`/`subtitle_key`/
`intro_duration`/`intro_style`), so the scenario file doesn't need to
hardcode chapter text. With arguments, it shows the given text directly
instead, ignoring `ChapterDef`, useful for an interstitial card or quick
testing.

### `@eyecatch`

```
@eyecatch <asset_id> [<duration>]
```

Opens a full-screen image card, blocking, that closes itself after
`<duration>`. `<asset_id>` is looked up as a CG first, then as a
background if that fails, so you can reuse a chapter's `@bg` image as
its eyecatch.

### `@datecard`

```
@datecard "<line1>" ["<line2>"] ["<line3>"]
```

Opens a date-card overlay with up to three lines of text, blocking.

Example: `@datecard "April 12" "Evening" "The Cottage"`
