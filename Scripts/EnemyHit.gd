extends Node2D

onready var hitEffect = get_node("EnemyHit")

func _ready():
	hitEffect.play()
	
func _on_EnemyHit_animation_finished():
	queue_free()
