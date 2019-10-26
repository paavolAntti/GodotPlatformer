extends KinematicBody2D

const normalGravity = 500.0
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
const climbSpeed = 50
const throwPower = 75
const throwTimer = 0.2
const throwRate = 0.5

var gravity = 500.0
var onLadder = false
var velocity = Vector2()
var onAirTime = 100
var jumpCount = 0
var jumping = false
var climbing = false
var facingRight = true
var throwTime = throwTimer
var timer = null
var canThrow = true

onready var playerSprite = self.get_node("PlayerSprite")
onready var throwable = preload("res://Scenes/Throwable.tscn")
onready var throwPos = self.get_node("ThrowPosition")

func _ready():
	#luodaan throwrate timer
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(throwRate)
	timer.connect("timeout", self, "timer_complete")
	add_child(timer)

func _physics_process(delta):
	move(delta)
	jump(delta)
	climb()
	animate()
	throw(delta)

func timer_complete():
	canThrow = true	
func climb():
	var climbUp = Input.is_action_pressed("ui_up")
	var climbDown = Input.is_action_pressed("ui_down")
	
	if onLadder:
		onAirTime = 0
		gravity = 0
		if climbUp:
			velocity.y = -climbSpeed
			climbing = true
			
		elif climbDown:
			velocity.y = climbSpeed
			climbing = true
		else:
			velocity.y = 0
	else:
		gravity = normalGravity
		climbing = false
	
func jump(delta):
	var jump = Input.is_action_just_pressed("JUMP")
	if jump:
		if onAirTime < jumpMaxAirborneTime and jumpCount < maxJumps:
			velocity.y = -jumpForce
			jumpCount += 1
	onAirTime += delta
	
func move(delta):
	var goLeft = Input.is_action_pressed("LEFT")
	var goRight = Input.is_action_pressed("RIGHT")
	var force = Vector2(0, gravity)
	var stop = true
	
	if goLeft:
		if velocity.x <= walkMin and velocity.x > -walkMax:
			force.x -= walkForce
			stop = false
			playerSprite.set_flip_h(true)
			facingRight = false
			
	elif goRight:
		if velocity.x >= -walkMin and velocity.x < walkMax:
			force.x += walkForce
			stop = false
			playerSprite.set_flip_h(false)
			facingRight = true

	if stop:
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)

		vlen -= stopForce * delta
		if vlen < 0:
			vlen = 0
		velocity.x = vlen * vsign
	if is_on_floor():
		onAirTime = 0
		jumpCount = 1
		jumping = false
		
	
	velocity += force * get_physics_process_delta_time()
	velocity = move_and_slide(velocity, Vector2(0,-1))

func animate():
	if velocity.length() > 0:
		playerSprite.play()
	elif playerSprite.animation == "idle":
		playerSprite.play()
	else:
		playerSprite.stop()
	if throwTime <= throwTimer:
		playerSprite.animation = "throw"
	elif velocity.y < 0 and not onLadder:
		playerSprite.animation = "jump"
	elif climbing:
		playerSprite.animation = "climb"
	elif velocity.y > 0:
		playerSprite.animation = "land"
	elif abs(velocity.x) == 0 and not jumping:
		playerSprite.animation = "idle"
	elif abs(velocity.x) > 0 and not jumping:
		playerSprite.animation = "run"
	

func throw(delta):
	var throw = Input.is_action_just_pressed("SHOOT")
	var cherry = throwable.instance()

	if throw and canThrow:
		throwTime = 0
		var direction = 1
		cherry.position = Vector2(throwPos.position.x, throwPos.position.y)
		add_child(cherry)
		if !facingRight:
			direction = -1
			cherry.position = Vector2(-throwPos.position.x, throwPos.position.y)
		cherry.launch(direction)
		canThrow = false
		timer.start()
	throwTime += delta