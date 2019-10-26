extends KinematicBody2D

const normalGravity = 500.0
const speed = 30
const ground = Vector2(0,-1)

var velocity = Vector2()

func _ready():
	pass

func _physics_process(delta):
	velocity.x = -speed 
	velocity.y = normalGravity

	velocity = move_and_slide(velocity, ground)
