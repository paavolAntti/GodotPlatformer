extends Node2D

onready var collect_animation = preload("res://Scenes/ItemFeedback.tscn").instance()

func _on_Gem_body_entered(body):
	if body.name == "Player":
		Globals.player_score += 2
		print("Player score: " + str(Globals.player_score))
		collect_animation.set_position(self.get_position())
		get_parent().add_child(collect_animation)
		queue_free()
