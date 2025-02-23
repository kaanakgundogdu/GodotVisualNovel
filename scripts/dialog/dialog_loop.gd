extends Node

class_name DialogLoop

@export var db_controller: DialogBoxController
@export var sb_controller: SpeakerBoxController
@export var dialog_reader: DialogReader

#var is_auto = true
var Dialogs
var Dialog_Index = 0
#var auto_timer: Timer
#var auto_delay = 0.6

func _ready():
	Dialogs = dialog_reader.get_dialogs("res://dialog/scene1/dialog1.json")
	if Dialogs == null:
		printerr("dialogs not found")
		return

	#print("id is ", Dialogs[0].id)
	#print("bde ", Dialogs[0]["before_dialog_event"][0].keys()[0])
	#if is_auto:
		#create_timer()
	
	put_dialog()

#
#func create_timer():
	#auto_timer = Timer.new()
	#add_child(auto_timer)
	#auto_timer.wait_time = auto_delay
	#auto_timer.one_shot = true
	#auto_timer.timeout.connect(_on_auto_timer_timeout)
#
## if auto button clicked make is auto false,
## kill timer and don't change dialog
#func toggle_auto():
	#is_auto = !is_auto
	#if is_auto:
		#if Dialog_Index < Dialogs.size():  
			#auto_timer.start()
	#else:
		#auto_timer.stop()
#
#func _on_auto_timer_timeout():
	#if is_auto:
		#put_dialog()
	#else:
		#auto_timer.stop()


func put_dialog():
	var dialog = get_dialog()
	if dialog == null:
		return

	set_dialog_and_speaker(dialog)

func get_dialog():
	if Dialogs.size() > Dialog_Index:
		var index = Dialog_Index
		Dialog_Index += 1
		return Dialogs[index]
	else:
		#var animation_controller = get_tree().get_first_node_in_group("CharacterAnimation") as CharacterAnimationController
		#if animation_controller:
			#print("stop anim")
			#animation_controller.stop_animation()
		return null

func set_dialog_and_speaker(current_dialog):
	set_sb(current_dialog)
	await set_db(current_dialog)
#
	#if is_auto:
		#print("auto call")
		#auto_timer.start()

func set_sb(current_dialog):
	sb_controller.update_speaker_box(current_dialog.speaker)

func set_db(current_dialog):
	await db_controller.update_dialog_box(current_dialog.dialog)
