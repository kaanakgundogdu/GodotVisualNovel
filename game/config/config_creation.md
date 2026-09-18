# Config creation

`game.tres` used to hold every chapter, ending, flag, character and credits
entry inline, and got too cluttered to find anything in the Inspector. It
was split: each entry now lives in its own small `.tres` file under a
matching subfolder (`chapters/`, `endings/`, `flags/`, `characters/`,
`credits/`, `boot/`, `asset_map/`). The folders with an unordered or long
list (`flags/`, `credits/`, `characters/`, `asset_map/`, `boot/`) also got a
`_<folder>.tres` index file that only references the entries, it doesn't
embed them.

See `addons/vn_engine/docs/CONFIG.md` for what each field does.
