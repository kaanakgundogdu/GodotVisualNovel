extends Node

class_name SpeakerBoxController

@export var speaker_name_path: Label
@onready var speaker_name_box = speaker_name_path

func update_speaker_box(sp_name: String):
	speaker_name_box.text = ""
	speaker_name_box.text = sp_name.to_upper()
