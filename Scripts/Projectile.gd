extends KinematicBody2D

const gravity = 600.0
const throw_velocity = Vector2(200, -100)

var velocity = Vector2()

onready var hit_effect = preload("res://Scenes/NormalHit.tscn").instance()
onready var enemy_hit_effect = preload("res://Scenes/EnemyHit.tscn").instance()


func _ready():
	set_physics_process(false)


func _physics_process(delta):
	velocity.y += Globals.normal_gravity * delta
	var collision = move_and_collide(velocity * delta)
	if collision != null:
		_on_collision(collision)


func launch(direction):
	var temp = global_transform
	var scene = get_tree().current_scene
	get_parent().remove_child(self)
	scene.add_child(self)
	global_transform = temp
	velocity = throw_velocity * Vector2(direction, 1)
	set_physics_process(true)


func _on_collision(collision):
	if collision.collider.is_in_group("enemies"):
		collision.collider.queue_free()
		enemy_hit_effect.set_position(self.get_position())
		get_parent().add_child(enemy_hit_effect)
		queue_free()
	else:
		hit_effect.set_position(self.get_position())
		get_parent().add_child(hit_effect)
		queue_free()