extends Node2D

class_name MenuUI

@export_group("CanvasLayer")
@export var canvas_layer: CanvasLayer

@export_group("Controller")
@export var main_menu_controller: MainMenuController

@export_group("Buttons")
@export var main_menu_button_path: Button

@onready var main_menu_button = main_menu_button_path

func _ready():
	print("MenuUI ready")
	main_menu_button.connect("pressed", Callable(self, "on_back_to_main_menu_button_pressed"))

func on_back_to_main_menu_button_pressed():
	main_menu_controller.open_main_menu()

func set_visibility(vis: bool) -> void:
	if canvas_layer:
		canvas_layer.visible = vis
		print("CanvasLayer visibility set to:", vis)
	else:
		print("CanvasLayer is not assigned!")
