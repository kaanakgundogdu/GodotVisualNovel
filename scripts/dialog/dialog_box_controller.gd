extends Node

class_name DialogBoxController

@export_group("SpeakerBoxController")
@export var spnode2_path: SpeakerBoxController
@onready var spnode2: SpeakerBoxController = spnode2_path

@export_group("DialogUtils")
const dialog_utils_path = "res://scripts/dialog/dialog_utils.gd"
@onready var dialog_utils = preload(dialog_utils_path).new()

@export var dialogbox_path: RichTextLabel
@onready var dialogbox = dialogbox_path

@export var delay_on_start = 0.3
@export var delay_for_messages = 0.3
@export var delay_for_character = 0.02

var is_auto = true
var dialog_idx = 0

var dixalogs = [
	"Hello, [b]Godot[/b] [shake][color=#fcba03]Visual Novel Engine[/color][/shake] test v1.\nHello, [b]Godot[/b] [color=#FF0000]Visual[/color] Novel Engine test v1.",
	"[i]Maybe Devlog[/i] coming soon. [color=#FF0000]Maybe not.[/color] I'm not sure.",
	"[shake]This is very simple, I know, but I love it.[/shake]\nI also found all of these [b]assets[/b] on the internet.\n[color=#FF0000]Bye![/color]"
]


func _ready():
	dialogbox.clear()
	await get_tree().create_timer(delay_on_start).timeout
	#var message = get_dialog(dialog_idx)
	#call_speaker_controller("asdsadsa")
	#await update_dialog_box(message)


#func call_speaker_controller(speaker_name: String):
	#print("Updating speaker box for: ", speaker_name)
	#spnode2.update_speaker_box(speaker_name)

#func dialog_loop():
	#if is_auto:
		#var dialog = get_dialog(dialog_idx)
		#await update_dialog_box(dialog)


#func next_dialog():
	#var dialog = get_dialog(dialog_idx)
	#await update_dialog_box(dialog)
#
#func get_dialog(idx):
	#print(dialogs.size())
	#if idx >= dialogs.size():
		#return null
#
	#return dialogs[idx]


func update_dialog_box(dialog):
	if dialog == null:
		return
	
	dialogbox.bbcode_text = dialog
	dialogbox.visible_characters = 0
	var visible_message = dialog_utils.strip_bbcode(dialog)
	var total_chars = visible_message.length() 
	for i in range(total_chars):
		dialogbox.visible_characters = i + 1
		await get_tree().create_timer(delay_for_character).timeout
	
	await get_tree().create_timer(delay_for_messages).timeout
	dialog_idx = dialog_idx + 1
	#dialog_loop()
