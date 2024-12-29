extends Node

class_name OptionsMenu

@export_group("Buttons")
@export var graphics_button_path: Button
@export var audio_button_path: Button
@export var save_button_path: Button
@export var load_button_path: Button
@export var main_menu_button_path: Button

@onready var graphics_button = graphics_button_path
@onready var audio_button = audio_button_path
@onready var save_button = save_button_path
@onready var load_button = load_button_path
@onready var main_menu_button = main_menu_button_path

@export_group("Scenes")
@export var graphics_scene_path: String
@export var audio_scene_path: String
@export var save_scene_path: String
@export var load_scene_path: String
@export var main_menu_scene_path: String

var is_loading = false

func _ready():
	graphics_button.connect("pressed", Callable(self, "on_graphics_button_pressed"))
	audio_button.connect("pressed", Callable(self, "on_audio_button_pressed"))
	save_button.connect("pressed", Callable(self, "on_save_button_pressed"))
	load_button.connect("pressed", Callable(self, "on_load_button_pressed"))
	main_menu_button.connect("pressed", Callable(self, "on_main_menu_button_pressed"))

func on_graphics_button_pressed():
	if is_loading:
		return
	get_tree().change_scene_to_file(graphics_scene_path)

func on_audio_button_pressed():
	if is_loading:
		return
	get_tree().change_scene_to_file(audio_scene_path)
	

func on_save_button_pressed():
	if is_loading:
		return
	get_tree().change_scene_to_file(save_scene_path)

func on_load_button_pressed():
	if is_loading:
		return
	get_tree().change_scene_to_file(load_scene_path)

func on_main_menu_button_pressed():
	if is_loading:
		return
	get_tree().change_scene_to_file(main_menu_scene_path)
