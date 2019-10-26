extends KinematicBody2D

const gravity = 600.0
const throwVelocity = Vector2(200, -100)
var velocity = Vector2()

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	velocity.y += gravity * delta
	var collision = move_and_collide(velocity * delta)
	if collision != null:
		_on_collision()

func launch(direction):
	var temp = global_transform
	var scene = get_tree().current_scene
	get_parent().remove_child(self)
	scene.add_child(self)
	global_transform = temp
	velocity = throwVelocity * Vector2(direction, 1)
	set_physics_process(true)

func _on_collision():
	pass