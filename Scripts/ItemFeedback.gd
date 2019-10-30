extends Node

onready var effect = get_child(1)

func _ready():
	effect.play()
	
func _on_AnimatedSprite_animation_finished():
	queue_free()
