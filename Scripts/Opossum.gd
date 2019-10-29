extends KinematicBody2D

const speed = 30

var velocity = Vector2()

func _ready():
	pass

func _physics_process(delta):
	velocity.x = -speed 
	velocity.y = Globals.normal_gravity

	velocity = move_and_slide(velocity, Globals.ground)
