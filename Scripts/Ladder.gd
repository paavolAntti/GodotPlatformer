extends Area2D

func _on_Ladder_body_entered(body):
	if body.name == "Player":
		get_node("../Player").on_ladder = true
		get_node("../Player").set_snap(false)

func _on_Ladder_body_exited(body):
	if body.name == "Player":
		get_node("../Player").on_ladder = false
		get_node("../Player").set_snap(true)
