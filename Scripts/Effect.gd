extends Node2D

onready var effect = get_node("Effect")
onready var sfx_player = self.get_node("SfxPlayer")

func _ready():
	effect.play()
	sfx_player.play()
	
func _on_Effect_animation_finished():
	queue_free()
