extends Area2D

onready var parent = get_parent()


func _on_HitBox_body_entered(body):
	if body.is_in_group("enemies") and !parent.isHurt:
		parent.hurt()
		print("AUCH")