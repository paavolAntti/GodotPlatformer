extends AnimatedSprite

func _on_Gem_body_entered(body):
	if body.name == "Player":
		Globals.player_score += 5
		queue_free()
