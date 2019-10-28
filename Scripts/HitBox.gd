extends Area2D

onready var parent = get_parent()


func _on_HitBox_body_entered(body):
	if body.is_in_group("enemies") and !parent.is_hurt:
		parent.hurt(parent.current_direction)
		print("Lives left: " + str(parent.player_lives))