class_name CommandContext
extends RefCounted

var runner: StoryRunner
var state: StoryState
var script_res: StoryScript
var bus: CommandBus

var background: BackgroundSystem
var characters: CharacterLayer
var audio: AudioSystem
var video: VideoSystem
var camera: CameraSystem
var dialog_ui: DialogUI

var assets: AssetResolver
