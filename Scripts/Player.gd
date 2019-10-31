extends KinematicBody2D

const walk_force = 100
const jump_force = 150
const max_airborne_time = 0.5
const max_jumps = 2
const climb_speed = 50
const throw_timer = 0.2
const throw_rate = 0.5
const hurt_time = 0.5
const max_ammo = 5

var gravity = Globals.normal_gravity
var on_air_time = 100
var jump_count = 0
var on_ladder = false
var jumping = false
var climbing = false
var can_throw = true
var velocity = Vector2()
var throw_time = throw_timer
var timer = null
var hurt_timer = null
var snap_vector = set_snap(true)
var is_hurt = false
var player_lives = 3
var current_ammo = max_ammo
var current_direction = 1

onready var player_animator = self.get_node("PlayerSprite")
onready var throwable = preload("res://Scenes/Throwable.tscn")
onready var projectile_origin = self.get_node("ThrowPosition")
onready var game_master = get_parent()

func _ready():
	throw_timer()
	hurt_timer()


func _physics_process(delta):
	if !is_hurt:
		get_input(delta)
		jump(delta)
		climb()
		throw(delta)
	animate()
	handle_velocity(delta)
	

func hurt_timer():
	hurt_timer = Timer.new()
	hurt_timer.set_one_shot(true)
	hurt_timer.set_wait_time(hurt_time)
	hurt_timer.connect("timeout", self, "hurt_timer_complete")
	add_child(hurt_timer)


func throw_timer():
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(throw_rate)
	timer.connect("timeout", self, "timer_complete")
	add_child(timer)


func timer_complete():
	can_throw = true


func hurt_timer_complete():
	is_hurt = false


func hurt(direction):
	if climbing:
		gravity = Globals.normal_gravity

	is_hurt = true
	hurt_timer.start()
	player_lives -= 1
	set_snap(false)
	velocity = Vector2(100, -100) * Vector2(-direction, 1)
	
	if player_lives <= 0:
		game_master.restart_scene()


func climb():
	var climb_up = Input.is_action_pressed("ui_up")
	var climb_down = Input.is_action_pressed("ui_down")
	
	if on_ladder and velocity.x == 0:
		on_air_time = 0
		gravity = 0
		jump_count = 1
		if climb_up:
			velocity.y = -climb_speed
			climbing = true
			
		elif climb_down:
			velocity.y = climb_speed
			climbing = true
		else:
			velocity.y = 0
	else:
		gravity = Globals.normal_gravity
		climbing = false

	
func jump(delta):
	var jump = Input.is_action_just_pressed("JUMP")

	if jump:
		if on_air_time < max_airborne_time and jump_count < max_jumps:
			set_snap(false)
			velocity.y = -jump_force
			jump_count += 1	
	on_air_time += delta	

	
func get_input(delta):
	if on_air_time >= max_airborne_time:
		set_snap(true)
	elif on_air_time == 0 and snap_vector == Vector2() and !on_ladder:
		set_snap(true)

	velocity.x = 0
	var left = Input.is_action_pressed("LEFT")
	var right = Input.is_action_pressed("RIGHT")
	
	if left:
		velocity.x -= walk_force
		player_animator.set_flip_h(true)
		current_direction = -1

	elif right:
		velocity.x += walk_force
		player_animator.set_flip_h(false)
		current_direction = 1
	


func handle_velocity(delta):
	if is_on_floor():
		on_air_time = 0
		jump_count = 1

	velocity.y += gravity * delta
	velocity = move_and_slide_with_snap(velocity, snap_vector,Globals.ground , true)

func animate():
	if velocity.length() > 0:
		player_animator.play()
	elif player_animator.animation == "idle":
		player_animator.play()
	else:
		player_animator.stop()
	if is_hurt:
		player_animator.animation = "hurt"
	elif throw_time <= throw_timer:
		player_animator.animation = "throw"
	elif velocity.y < 0 and not on_ladder and !is_on_floor():
		player_animator.animation = "jump"
	elif on_ladder and velocity.x == 0:
		player_animator.animation = "climb"
	elif velocity.y > 0 and !is_on_floor():
		player_animator.animation = "land"
	elif abs(velocity.x) == 0 and not jumping:
		player_animator.animation = "idle"
	elif abs(velocity.x) > 0 and not jumping:
		player_animator.animation = "run"
	

func throw(delta):
	var throw = Input.is_action_just_pressed("SHOOT")
	var cherry = throwable.instance()

	if throw and can_throw and current_ammo > 0:
		current_ammo -= 1
		throw_time = 0
		var direction = 1
		cherry.position = Vector2(projectile_origin.position.x, projectile_origin.position.y) * Vector2(current_direction, 1)
		add_child(cherry)
		cherry.launch(current_direction)
		can_throw = false
		timer.start()
	throw_time += delta


func set_snap(toggle):
	if toggle:
		snap_vector = Vector2(0, 32)
	else:
		snap_vector = Vector2()

