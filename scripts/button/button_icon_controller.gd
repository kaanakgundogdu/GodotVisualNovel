extends Node

class_name ButtonIconController

@export_group("Buttons")
@export var button_path: Button
@onready var button = button_path

@export var button_icon_path: Polygon2D # change to image later
@onready var button_icon = button_icon_path

var original_color : Color

func _ready():
 original_color = button_icon.color
 button.connect("button_down", Callable(self, "_on_button_pressed"))
 button.connect("button_up", Callable(self, "_on_button_released"))

func _on_button_pressed():
 button_icon.color.a = 0.5

func _on_button_released():
 button_icon.color = original_color
