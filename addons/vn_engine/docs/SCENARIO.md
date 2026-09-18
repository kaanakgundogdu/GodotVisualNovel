# Writing scenario files

A scenario file is plain text with the extension `.txt`. `ScenarioParser`
(`addons/vn_engine/core/story/scenario_parser.gd`) reads the file and builds a
`StoryScript`.

## Where files live

```
<content root>/scenario/<chapter_id>/*.txt
```

The default content root is `res://game/`, so a real path looks like
`res://game/scenario/chapter1/scenario1.txt`. `<chapter_id>` is the folder
name and it becomes a prefix on every line id in that file (see
[Line ids](#line-ids)). `ChapterDef.script_path` in `config/chapters/<id>.tres`
points at the actual file (see `CONFIG.md`).

## A minimal example

```
// Intro scene, comments start with two slashes.
# start
@bg bg_cottage_ext_day
@music bgm_calm
Narrator: The sun was setting over the hills.

# meet | greet
@show hana normal at left
Hana(happy)[wave]: Hey! Over here.

- Wave back. -> wave_back
- Ignore her and walk past. -> ignore once

# wave_back
@flag waved = true
Hana: Good, you're not blind after all.
@jump ending

# ignore
Narrator: You walk past without a word.
@jump ending

# ending
@jump_if waved == true -> good_end
@jump bad_end

# good_end
Hana: See you tomorrow!
@end good

# bad_end
Narrator: She frowns and walks away.
@end bad
```

This is a full, working file: node headers, an alias, dialog with an
expression and an animation, a narrator line, a choice with `once`, a flag
write, and a conditional jump.

## Line types

| Line type | Example | Notes |
|---|---|---|
| Comment | `// note` | Ignored. Must be the whole line (starts with `//`). |
| Node header | `# start` | Starts a new node. Everything after the node header belongs to that node until the next header. |
| Node header, explicit id | `# id: start` | Same as `# start`, the `id:` prefix is optional. |
| Node header with alias | `# start\|s` | Registers two ids for the same node, `start` and `s`. Either can be used as a jump/choice target. Can't combine this with the `id:` prefix on the same line. |
| Dialog line | `Hana: Hello.` | `speaker_id: text`. `speaker_id` is lowercased automatically. |
| Dialog with expression/animation | `Hana(happy)[wave]: Hey!` | `(expression)` and `[animation]` are both optional, either order. Passed straight to `@show`/the sprite system. |
| Narrator line | `Narrator: The sun sets.` | Just a dialog line with speaker id `narrator`. The name is not shown for it. |
| Choice line | `- text -> target [if cond] [disabled_if cond] [once]` | See below. |
| Command line | `@bg bg_cottage_ext_day` | Full list in `COMMANDS.md`. |

A blank line is ignored. A node can have **at most one** dialog line; a
second one is a parse error. A line that starts with none of `#`, `@`, `-`
and has no `:` is reported as "Unrecognized line".

### Choice line in detail

```
- <text> -> <target> [if <condition>] [disabled_if <condition>] [once]
```

- `<target>` is a node id or alias.
- `if <condition>` hides the choice when the condition is false.
- `disabled_if <condition>` keeps the choice visible but greyed out/unusable
  when the condition is true.
- `once` hides the choice after it has been picked one time.
- All three modifiers are optional and can be combined, in any order shown
  above.

### The dialog box during a choice-only node

If a node has choices but no dialog line of its own, the dialog box does
not clear. Whatever line was shown before (usually the question the
choices are answering) just stays on screen while the player picks.

If you want a specific line above the choices instead, give the node its
own `Speaker: text` line and it is shown as the prompt:

```
# meet
Hana: Where should we go?

- The park. -> park
- The cafe. -> cafe
```

Without that `Hana:` line, the node would just keep showing whatever the
previous node last displayed.

### Escaping text

In dialog text, `\n` becomes a real newline and `\\` becomes a literal
backslash. Nothing else is escaped.

## Conditions (expressions)

`if`, `disabled_if`, and `@jump_if` all use the same small expression
grammar, evaluated by `ExpressionEvaluator`
(`addons/vn_engine/core/story/expression_evaluator.gd`). It is not GDScript
and not Godot's `Expression` class on purpose, so scenario content can't run
arbitrary code.

**Works:**

| Thing | Example |
|---|---|
| `and`, `or`, `not` (case-insensitive words) | `hana_affection >= 5 and not teased_hana` |
| Parentheses | `(a or b) and c` |
| Comparisons | `== != < <= > >=` |
| `+` and `-` (binary only) | `hana_affection + 1 >= 10` |
| Numbers | `5`, `3.5` |
| `true` / `false` | `teased_hana == true` |
| Quoted strings | `route == "hana"` |
| A flag name, bare | `took_tour` |

**Does not work:**

- `&&`, `\|\|`: not supported, use `and` / `or`.
- `!` for negation: not supported, use `not`.
- Unary minus (`-5` as a standalone value): only the binary `a - b` form
  works.
- No function calls, no Godot `Expression` class, no arbitrary GDScript.
- Ordering operators (`< > <= >=`) can't be used with a string literal or
  with a `bool`-typed flag. Use `==` / `!=` for those.

A flag name in a condition is matched case-insensitively, same as
`@set_var`/`@flag` (`hana_affection` and `Hana_Affection` are the same
flag).

## BBCode

Dialog text supports BBCode (`bbcode_enabled = true` on the dialog label).
`[b]bold[/b]`, `[i]italic[/i]`, `[color=red]...[/color]`, `[center]...[/center]`,
and other standard Godot RichTextLabel tags work as-is, no escaping needed.

## Line ids

Every node gets a `line_id`, built as `<chapter_id>.<node_id>`, e.g.
`chapter1.start`. Each choice on that node gets its own id too:
`<node_line_id>.c1`, `.c2`, and so on, in source order.

The line id is a stable key for the dialog line, used as the translation key
(`TranslationServer.translate(line_id)`, see `vn_text.gd`) and to find the
matching voice file (`<lang>/<speaker_id>/<line_id>`, see
`asset_resolver.gd`). It stays the same as long as the node id and the
chapter folder don't change, so renaming node ids or moving a scenario file
to a different chapter folder breaks existing translations and voice files.

## Common mistakes

These are the actual messages `ScenarioLinter`
(`addons/vn_engine/core/story/scenario_linter.gd`) and the parser produce.

| Message | Meaning |
|---|---|
| `This node is not targeted from anywhere and the previous node is terminal (unreachable)` | Nothing jumps or chooses into this node, and the node before it ends the flow (last node, has `@end`, has an unconditional `@jump`, or has choices). Dead content. |
| `Choice target not found: '<id>'` | A choice's `-> target` doesn't match any node id or alias. |
| `'@jump' target not found: '<id>'` / `'@jump_if' target not found: '<id>'` / `'@call' target not found: '<id>'` | Same, for `@jump`/`@jump_if`/`@call`. |
| `Unknown command: '@<name>'` | The command isn't in `CommandRegistry`. Check spelling, the linter also suggests a close match if it finds one. |
| `Undefined flag: '<id>'` | Only shown when a `FlagList` is passed to the parser. The flag isn't defined in `config/flags/`. |
| `Empty node header` | A line was just `#` with nothing after it. |
| `'<id>' is already defined at line <n>` | Two node headers (or a header and an alias) use the same id. Ids must be unique in the file. |
| `This node already has dialog at line <n>` | A node can only have one dialog line. The second one is rejected. |
| `Content line before node header` | A command/dialog/choice line appears before the file's first `# <node>` header. |
| `Speaker section could not be parsed, the whole line is treated as narrator text` | The part before `:` didn't look like a valid speaker (often a space in the speaker id). The whole line is shown as narrator text instead. |
| `'<id>' speaks with no sprite on screen` | INFO, only shown with verbose logging. A character talks before any `@show <id>`. Fine for an off-screen voice, a missing `@show` otherwise. |
| `Using the old positional '@jump_if' form` | `@jump_if <var> <op> <value> <target>` still works but is deprecated, switch to `@jump_if <condition> -> <target>`. |
| `Division by zero, the operation will not run` | `@set_var`/`@flag` with `/= 0`. |
| `'@jump' is ignored when choices are present` | A node has both choices and a `@jump`; choices win, the `@jump` never runs. |

## Scenario commands

The `@` lines you see in the examples above (`@bg`, `@music`, `@jump`, and
so on) are scenario commands, part of the scenario language itself, not a
separate debug tool. The full list, with argument syntax for each one, is
in [`COMMANDS.md`](COMMANDS.md).
