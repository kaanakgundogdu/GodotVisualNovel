extends Node2D

class_name MainMenu

@export_group("MainMenuController")
@export var main_menu_controller: MainMenuController

@export_group("CanvasLayer")
@export var main_menu_canvas_layer: CanvasLayer

@export_group("Buttons")
@export var load_button_path: Button
@export var new_game_button_path: Button
@export var options_button_path: Button
@export var credits_button_path: Button
@export var quit_button_path: Button

@export_group("Scenes")
@export var new_game_scene_path: PackedScene

@onready var load_button = load_button_path
@onready var new_game_button = new_game_button_path
@onready var options_button = options_button_path
@onready var credits_button = credits_button_path
@onready var quit_button = quit_button_path

func _ready():
	#load_button.connect("pressed", Callable(self, "on_load_button_pressed"))
	new_game_button.connect("pressed", Callable(self, "on_new_game_button_pressed"))	
	#options_button.connect("pressed", Callable(self, "on_options_button_pressed"))	
	#credits_button.connect("pressed", Callable(self, "on_credits_button_pressed"))
	quit_button.connect("pressed", Callable(self, "on_quit_button_pressed"))

func set_visibility(vibility: bool) -> void:
	main_menu_canvas_layer.visible = vibility

func on_load_button_pressed():
	main_menu_controller.open_load_menu()

func on_new_game_button_pressed():
	get_tree().change_scene_to_packed(new_game_scene_path)

func on_options_button_pressed():
	main_menu_controller.open_opts_menu()

func on_credits_button_pressed():
	main_menu_controller.open_credits_menu()

func on_quit_button_pressed():
	get_tree().quit()
