extends KinematicBody2D

const gravity = 500.0
const floorAngleTolerance = 40
const walkForce = 100
const walkMin = 10
const walkMax = 150
const stopForce = 1300
const jumpForce = 150
const jumpMaxAirborneTime = 0.5
const slideStopVelocity = 1.0
const slideStopMinTravel = 1.0
const maxJumps = 2

var velocity = Vector2()
var onAirTime = 100
var jumpCount = 0
var facingRight = true

onready var playerSprite = self.get_node("Sprite")


func _physics_process(delta):
	var force = Vector2(0, gravity)
	
	var goLeft = Input.is_action_pressed("LEFT")
	var goRight = Input.is_action_pressed("RIGHT")
	var jump = Input.is_action_just_pressed("JUMP")

	var stop = true
	
	if goLeft:
		if velocity.x <= walkMin and velocity.x > -walkMax:
			force.x -= walkForce
			stop = false
			playerSprite.set_flip_h(true)
			

	elif goRight:
		if velocity.x >= -walkMin and velocity.x < walkMax:
			force.x += walkForce
			stop = false
			playerSprite.set_flip_h(false)
	
	if stop:
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)

		vlen -= stopForce * delta
		if vlen < 0:
			vlen = 0
		velocity.x = vlen * vsign

	if is_on_floor():
		onAirTime = 0
		jumpCount = 0
		
	
	velocity += force * get_physics_process_delta_time()
	velocity = move_and_slide(velocity, Vector2(0,-1))
	
	
	if jump:
		if onAirTime < jumpMaxAirborneTime and jumpCount < maxJumps:
			velocity.y = -jumpForce
			jumpCount += 1
	onAirTime += delta
	


		


			
	

	

	

	

	
	
		
