extends KinematicBody2D

const max_walk_force = 100
const walk_force_increase = 10
const jump_force = 150
const max_airborne_time = 0.5
const max_jumps = 2
const climb_speed = 50
const throw_timer = 0.2
const throw_rate = 0.5
const hurt_time = 0.5
const max_ammo = 5
const stop_force = 10

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

onready var sfx_player = self.get_node("SfxPlayer")
onready var player_animator = self.get_node("PlayerSprite")
onready var throwable = preload("res://Scenes/Throwable.tscn")
onready var projectile_origin = self.get_node("ThrowPosition")
onready var game_master = get_parent()

onready var jump_sound = preload("res://Assets/Sfx/Jump.wav")
onready var hurt_sound = preload("res://Assets/Sfx/Hit_Hurt.wav")


func _ready():
	throw_timer()
	hurt_timer()


func _physics_process(delta):
	if !is_hurt:
		handle_input(delta)
	animate()
	handle_velocity_and_time(delta)
	
	

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
	sfx_player.set_stream(hurt_sound)
	sfx_player.play()
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
	
	if on_ladder:
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
	if on_air_time < max_airborne_time and jump_count < max_jumps:
		sfx_player.set_stream(jump_sound)
		sfx_player.play()
		set_snap(false)
		velocity.y = -jump_force
		jump_count += 1	
	on_air_time += delta

func run(direction, facing_right):
	velocity.x += walk_force_increase*direction
	if velocity.x > max_walk_force:
		velocity.x = max_walk_force
	if velocity.x < -max_walk_force:
		velocity.x = -max_walk_force
	player_animator.set_flip_h(facing_right)
	current_direction = direction

func stop():
	if velocity.x > 0:
		velocity.x -= stop_force 
		if velocity.x < 0:
			velocity.x = 0
	elif velocity.x < 0:
		velocity.x += stop_force
		if velocity.x > 0:
			velocity.x = 0

	
func handle_input(delta):
	if on_air_time >= max_airborne_time:
		set_snap(true)
	elif on_air_time == 0 and snap_vector == Vector2() and !on_ladder:
		set_snap(true)

	var left = Input.is_action_pressed("LEFT")
	var right = Input.is_action_pressed("RIGHT")
	var jump = Input.is_action_just_pressed("JUMP")
	var throw = Input.is_action_just_pressed("SHOOT")
	climb()
	if jump:
		jump(delta)
	if throw:
		throw(delta)
	if left and velocity.x >= -max_walk_force:
		run(-1, true)
	if right and velocity.x <= max_walk_force:
		run(1, false)
	elif !right and !left:
		stop()
	
	
func handle_velocity_and_time(delta):
	if is_on_floor():
		on_air_time = 0
		jump_count = 1
	throw_time += delta	
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
	elif on_ladder and climbing:
		player_animator.animation = "climb"
	elif velocity.y > 0 and !is_on_floor():
		player_animator.animation = "land"
	elif abs(velocity.x) == 0 and not jumping:
		player_animator.animation = "idle"
	elif abs(velocity.x) > 0 and not jumping:
		player_animator.animation = "run"
	

func throw(delta):
	if  can_throw and current_ammo > 0:
		var cherry = throwable.instance()
		current_ammo -= 1
		throw_time = 0
		var direction = 1
		cherry.position = Vector2(projectile_origin.position.x, projectile_origin.position.y) * Vector2(current_direction, 1)
		add_child(cherry)
		cherry.launch(current_direction)
		can_throw = false
		timer.start()
	

func set_snap(toggle):
	if toggle:
		snap_vector = Vector2(0, 32)
	else:
		snap_vector = Vector2()

