extends Node2D

onready var hitEffect = get_node("HitEffect")

func _ready():
	hitEffect.play("default")

	
func _on_AnimatedSprite_animation_finished():
	queue_free()