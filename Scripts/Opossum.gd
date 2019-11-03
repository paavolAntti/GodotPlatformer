extends KinematicBody2D

const speed = 30

var velocity = Vector2()

func _ready():
	pass

func _physics_process(delta):
	velocity.x = -speed 
	velocity.y += Globals.normal_gravity * delta

	velocity = move_and_slide_with_snap(velocity,Vector2(0, 32), Globals.ground)
