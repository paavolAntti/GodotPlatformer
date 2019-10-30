extends Node2D

onready var effect = get_node("Effect")

func _ready():
	effect.play()
	
func _on_Effect_animation_finished():
	queue_free()
