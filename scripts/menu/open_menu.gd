extends Node

class_name OpenMenu

@export_group("Buttons")
@export var menu_button_path: Button

@export_group("Scenes")
@export var menu_scene_path: String

@onready var menu_button = menu_button_path

var is_loading = false

func _ready():
	menu_button.connect("pressed", Callable(self, "on_menu_button_pressed"))


func on_menu_button_pressed():
	if is_loading:
		return

	is_loading = true
	if menu_scene_path != null:
		get_tree().change_scene_to_file(menu_scene_path)
	else:
		print("Error: menu_scene_path is not assigned!")

