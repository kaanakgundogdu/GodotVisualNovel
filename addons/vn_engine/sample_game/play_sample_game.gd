extends Node

func _ready() -> void:
	VNGame.use_content_root("res://addons/vn_engine/sample_game/")
	get_tree().change_scene_to_file.call_deferred("res://addons/vn_engine/flow/scenes/vn_main.tscn")
