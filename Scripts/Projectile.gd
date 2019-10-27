extends KinematicBody2D

const gravity = 600.0
const throwVelocity = Vector2(200, -100)

var velocity = Vector2()

onready var hitEffect = preload("res://Scenes/NormalHit.tscn").instance()
onready var enemyHitEffect = preload("res://Scenes/EnemyHit.tscn").instance()


func _ready():
	set_physics_process(false)


func _physics_process(delta):
	velocity.y += gravity * delta
	var collision = move_and_collide(velocity * delta)
	if collision != null:
		_on_collision(collision)


func launch(direction):
	var temp = global_transform
	var scene = get_tree().current_scene
	get_parent().remove_child(self)
	scene.add_child(self)
	global_transform = temp
	velocity = throwVelocity * Vector2(direction, 1)
	set_physics_process(true)


func _on_collision(collision):
	if collision.collider.is_in_group("enemies"):
		collision.collider.queue_free()
		enemyHitEffect.set_position(self.get_position())
		get_parent().add_child(enemyHitEffect)
		queue_free()
	else:
		hitEffect.set_position(self.get_position())
		get_parent().add_child(hitEffect)
		queue_free()