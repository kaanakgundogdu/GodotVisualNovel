# Config creation

Same split as `game/`: each chapter, ending, flag, character and asset map
entry lives in its own small `.tres` file under a matching subfolder, and
the folders with a list (`flags/`, `characters/`, `asset_map/`) have a
`_<folder>.tres` index file that only references the entries. This content
root has no boot sequence, credits, or custom screens set up, so there is
no `boot/`, `credits/`, or `screens/extras.tres` / `screens/ui.tres` here.

See `addons/vn_engine/docs/CONFIG.md` for what each field does.
