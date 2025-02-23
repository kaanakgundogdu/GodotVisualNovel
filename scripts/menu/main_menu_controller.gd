extends Node2D

class_name MainMenuController

@export var main_menu_ui : MainMenu
#@export var options_menu_ui : OptionsMenu
#@export var load_saves_ui : LoadSave
#@export var credits_ui : Credits

#@onready var menus = [main_menu_ui, options_menu_ui, load_saves_ui, credits_ui]

func _ready():
	open_main_menu()

#func close_all_menus():
	#for el in menus:
		#el.set_visibility(false)

func open_main_menu():
	#close_all_menus()
	main_menu_ui.set_visibility(true)

#func open_load_menu():
	#close_all_menus()
	#load_saves_ui.set_visibility(true)
#
#func open_credits_menu():
	#close_all_menus()
	#credits_ui.set_visibility(true)
#
#func open_opts_menu():
	#close_all_menus()
	#options_menu_ui.set_visibility(true)
