extends MenuUI

class_name OptionsMenu

@export_group("Buttons")
@export var graphics_button_path: Button
@export var audio_button_path: Button
@export var save_button_path: Button
@export var load_button_path: Button

@onready var graphics_button = graphics_button_path
@onready var audio_button = audio_button_path
@onready var save_button = save_button_path
@onready var load_button = load_button_path

@export_group("MenuScenes")
@export var graph_menu_ui : MainMenu
@export var audio_menu_ui : OptionsMenu
@export var saves_ui : LoadSave
@export var load_saves_ui : LoadSave
@export var credits_ui : Credits

@onready var menus = [graph_menu_ui, audio_menu_ui, saves_ui, load_saves_ui, credits_ui]


func _ready():
	super._ready()
	graphics_button.connect("pressed", Callable(self, "on_graphics_button_pressed"))
	audio_button.connect("pressed", Callable(self, "on_audio_button_pressed"))
	save_button.connect("pressed", Callable(self, "on_save_button_pressed"))
	load_button.connect("pressed", Callable(self, "on_load_button_pressed"))
	close_all_menus()


func close_all_menus():
	pass

func on_graphics_button_pressed():
	print("on_graphics_button_pressed")

func on_audio_button_pressed():
	print("on_audio_button_pressed")

func on_save_button_pressed():
	print("on_save_button_pressed")

func on_load_button_pressed():
	print("on_load_button_pressed")
