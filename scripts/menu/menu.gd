extends Node

class_name Menu

@export_group("Buttons")
## Drag and drop your button.
@export var play_button_path: Button
## Drag and drop your button.
@export var options_button_path: Button
## Drag and drop your button.
@export var quit_button_path: Button

@export_group("Scenes")
## Drag and drop your play scene.
@export var play_scene_path: PackedScene
## Drag and drop your options scene.
@export var options_scene_path: PackedScene

@onready var play_button = play_button_path
@onready var options_button = options_button_path
@onready var quit_button = quit_button_path

func _ready():
	play_button.connect("pressed", Callable(self, "on_play_button_pressed"))
	options_button.connect("pressed", Callable(self, "on_options_button_pressed"))
	quit_button.connect("pressed", Callable(self, "on_quit_button_pressed"))

func on_play_button_pressed():
	get_tree().change_scene_to_packed(play_scene_path)

func on_options_button_pressed():
	get_tree().change_scene_to_packed(options_scene_path)

func on_quit_button_pressed():
	get_tree().quit()
