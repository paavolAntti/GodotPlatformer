extends Node2D

onready var dialog_box_scene = preload("res://Scenes/DialogBox.tscn")
var dialog_box = null 
const dialog_pos = Vector2(-50, -100)

	
	
func _on_Area2D_body_entered(body):
	if body.name == "Player":
		dialog_box = dialog_box_scene.instance()
		dialog_box.set_position(self.get_position() + dialog_pos)
		get_parent().add_child(dialog_box)


func _on_Area2D_body_exited(body):
	if body.name == "Player":
		dialog_box.queue_free()