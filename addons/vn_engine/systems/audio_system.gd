class_name AudioSystem
extends Node

@export var runner: StoryRunner
@export var channels: Array[AudioChannel] = []
@export var crossfade_duration: float = 1.0

var _players: Dictionary = {}
var _tweens: Dictionary = {}
var _current_files: Dictionary = {}


func _ready() -> void:
	add_to_group(&"vn_audio_system")

	if runner:
		runner.state_restored.connect(_on_state_restored)
		runner.register_manager(self)

	for channel: AudioChannel in channels:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = channel.command_name.capitalize() + "Player"
		player.bus = channel.bus_name
		add_child(player)

		_players[channel.command_name] = {
			"config": channel,
			"node": player,
		}


func _on_state_restored(state: StoryState) -> void:
	for key: String in _players.keys():
		var target_file: String = state.audio.get(key, "")
		if target_file == _current_files.get(key, ""):
			continue

		if target_file == "":
			_stop_audio(key)
		else:
			_play_audio(key, target_file)


func play_channel(channel_name: String, file_name: String, speaker_id: String = "") -> void:
	if _players.has(channel_name):
		_play_audio(channel_name, file_name, speaker_id)


func play_bgm(resolved_path: String) -> void:
	if resolved_path == "" or not _players.has("music"):
		return
	_play_audio("music", resolved_path, "", resolved_path)


func stop_bgm() -> void:
	if _players.has("music"):
		_stop_audio("music")


func _play_audio(channel_name: String, file_name: String, speaker_id: String = "", resolved_path: String = "") -> void:
	var data: Dictionary = _players[channel_name]
	var config: AudioChannel = data["config"]
	var player: AudioStreamPlayer = data["node"]

	if file_name.to_lower() == "stop":
		_stop_audio(channel_name)
		return

	if file_name == _current_files.get(channel_name, ""):
		return

	if channel_name == "music":
		_silence_other_music_players()

	var file_path: String = resolved_path
	if file_path == "":
		file_path = runner.ctx.assets.resolve(channel_name, file_name)

	if file_path == "":
		return

	var new_stream: AudioStream = load(file_path) as AudioStream
	_current_files[channel_name] = file_name

	var base_db: float = config.base_volume_db

	if channel_name == "voice" and speaker_id != "":
		var voice_mult: float = VNSettings.data["audio"]["voice_volume"].get(speaker_id, 1.0)
		base_db += maxf(linear_to_db(voice_mult), -80.0)

	if config.use_fade:
		if _tweens.has(channel_name) and _tweens[channel_name].is_valid():
			_tweens[channel_name].kill()

		var tween: Tween = create_tween()
		_tweens[channel_name] = tween

		if player.playing:
			tween.tween_property(player, "volume_db", base_db - 40.0, crossfade_duration / 2.0)
			tween.tween_callback(func() -> void:
				player.stream = new_stream
				player.play()
			)
			tween.tween_property(player, "volume_db", base_db, crossfade_duration / 2.0)
		else:
			player.stream = new_stream
			player.volume_db = base_db - 40.0
			player.play()
			tween.tween_property(player, "volume_db", base_db, crossfade_duration)
	else:
		player.stream = new_stream
		player.volume_db = base_db
		player.play()


func _stop_audio(channel_name: String) -> void:
	var data: Dictionary = _players[channel_name]
	var config: AudioChannel = data["config"]
	var player: AudioStreamPlayer = data["node"]

	_current_files[channel_name] = ""

	var base_db: float = config.base_volume_db

	if config.use_fade:
		if _tweens.has(channel_name) and _tweens[channel_name].is_valid():
			_tweens[channel_name].kill()

		var tween: Tween = create_tween()
		_tweens[channel_name] = tween
		tween.tween_property(player, "volume_db", base_db - 80.0, crossfade_duration)
		tween.tween_callback(player.stop)
	else:
		player.stop()


func _silence_other_music_players() -> void:
	for node: Node in get_tree().get_nodes_in_group(&"vn_audio_system"):
		if node == self:
			continue
		if node is AudioSystem:
			(node as AudioSystem).stop_bgm()
