tool
extends Node2D

func _ready():
	$AnimatedSprite.connect("animation_finished", self, "queue_free")
