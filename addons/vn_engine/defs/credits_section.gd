@tool
class_name CreditsSection
extends Resource

## Translation key for this role's label, like "credits.role.director".
@export var role_key: String = ""
## Proper names for this role, listed as they should display. Not
## translated.
@export var names: PackedStringArray = []
