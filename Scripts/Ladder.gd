extends Area2D

func _on_Ladder_body_entered(body):
	if body.name == "Player":
		get_node("../Player").onLadder = true
		get_node("../Player").snapVector = Vector2()

func _on_Ladder_body_exited(body):
	if body.name == "Player":
		get_node("../Player").onLadder = false
		get_node("../Player").snapVector = Vector2(0, 32)


