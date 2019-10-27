extends KinematicBody2D

const normalGravity = 500.0
const walkForce = 100
const jumpForce = 150
const jumpMaxAirborneTime = 0.5
const maxJumps = 2
const climbSpeed = 50
const throwTimer = 0.2
const throwRate = 0.5
const hurtTime = 0.5

var gravity = 500.0
var onAirTime = 100
var jumpCount = 0
var onLadder = false
var jumping = false
var climbing = false
var facingRight = true
var canThrow = true
var velocity = Vector2()
var throwTime = throwTimer
var timer = null
var hurtTimer = null
var snapVector = Vector2(0, 32)
var hurt = false

onready var playerSprite = self.get_node("PlayerSprite")
onready var throwable = preload("res://Scenes/Throwable.tscn")
onready var throwPos = self.get_node("ThrowPosition")

func _ready():
	throw_timer()
	hurt_timer()


func _physics_process(delta):
	move(delta)
	jump(delta)
	climb()
	animate()
	throw(delta)
	

func hurt_timer():
	hurtTimer = Timer.new()
	hurtTimer.set_one_shot(true)
	hurtTimer.set_wait_time(hurtTime)
	hurtTimer.connect("timeout", self, "hurt_timer_complete")
	add_child(hurtTimer)


func throw_timer():
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(throwRate)
	timer.connect("timeout", self, "timer_complete")
	add_child(timer)


func timer_complete():
	canThrow = true


func hurt_timer_complete():
	hurt = false


func climb():
	var climbUp = Input.is_action_pressed("ui_up")
	var climbDown = Input.is_action_pressed("ui_down")
	
	if onLadder:
		snapVector = Vector2(0, 0)
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
			snapVector = Vector2(0, 0)
			velocity.y = -jumpForce
			jumpCount += 1	
	onAirTime += delta	

	
func move(delta):
	if onAirTime >= jumpMaxAirborneTime:
		snapVector = Vector2(0, 32)

	velocity.x = 0
	var goLeft = Input.is_action_pressed("LEFT")
	var goRight = Input.is_action_pressed("RIGHT")
	
	if goLeft:
		velocity.x -= walkForce
		playerSprite.set_flip_h(true)
		facingRight = false

	elif goRight:
		velocity.x += walkForce
		playerSprite.set_flip_h(false)
		facingRight = true
	
	if is_on_floor():
		onAirTime = 0
		jumpCount = 1

	velocity.y += gravity * delta
	velocity = move_and_slide_with_snap(velocity, snapVector, Vector2(0,-1), true)
	

func animate():
	if velocity.length() > 0:
		playerSprite.play()
	elif playerSprite.animation == "idle":
		playerSprite.play()
	else:
		playerSprite.stop()
	if hurt:
		playerSprite.animation = "hurt"
	elif throwTime <= throwTimer:
		playerSprite.animation = "throw"
	elif velocity.y < 0 and not onLadder and !is_on_floor():
		playerSprite.animation = "jump"
	elif climbing:
		playerSprite.animation = "climb"
	elif velocity.y > 0 and !is_on_floor():
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
