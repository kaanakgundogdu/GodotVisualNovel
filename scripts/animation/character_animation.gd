extends Node2D

class_name CharacterAnimationController

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	play_idle_animation()

func play_idle_animation():
	animated_sprite.animation = "idle"
	animated_sprite.play()

func play_talk_animation():
	animated_sprite.animation = "talk"
	animated_sprite.play()

func stop_animation():
	animated_sprite.stop()
