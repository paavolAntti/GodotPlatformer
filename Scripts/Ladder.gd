extends Area2D

func _on_Ladder_body_entered(body):
	print("tapahtuma")
	if body.name == "Player":
		get_node("../Player").onLadder = true
	if body.is_in_group("projectile"):
		body.queue_free()

func _on_Ladder_body_exited(body):
	if body.name == "Player":
		get_node("../Player").onLadder = false


