tool
extends Node2D

func _ready():
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play("default")
	$AnimatedSprite.connect("animation_finished", self, "queue_free")
	pass
