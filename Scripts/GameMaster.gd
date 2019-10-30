extends Node2D

onready var player_scene = preload("res://Scenes/Player.tscn")
onready var opossum_scene = preload("res://Scenes/Opossum.tscn")
onready var enemy_spawn_positions = [get_node("EnemySpawn1"), get_node("EnemySpawn2")]
const spawn_rate = 4.0
const max_enemies = 2

var current_enemies = 0
var can_spawn = true
var spawn_timer = null
var player = null

func _ready():
	enemy_spawn_timer()
	spawn_player()
	

func _process(delta):
	if current_enemies < max_enemies and can_spawn:
		spawn_enemy(enemy_spawn_positions[randi()%enemy_spawn_positions.size()])
	handle_score()


func spawn_player():
	var spawn = get_node("SpawnPoint")
	player = player_scene.instance()
	player.position = Vector2(spawn.position.x, spawn.position.y)
	add_child(player)


func spawn_enemy(spawnPos):
	var enemy = opossum_scene.instance()
	enemy.position = Vector2(spawnPos.position.x, spawnPos.position.y)
	add_child(enemy)
	print("spawned enemy")
	current_enemies +=1
	can_spawn = false
	spawn_timer.start()


func timer_complete():
	can_spawn = true
	

func restart_scene():
	get_tree().reload_current_scene()


func enemy_spawn_timer():
	spawn_timer = Timer.new()
	spawn_timer.set_one_shot(true)
	spawn_timer.set_wait_time(spawn_rate)
	spawn_timer.connect("timeout", self, "timer_complete")
	add_child(spawn_timer)

func handle_score():
	if Globals.player_score >= 100:
		player.player_lives += 1
		Globals.player_score = 0



