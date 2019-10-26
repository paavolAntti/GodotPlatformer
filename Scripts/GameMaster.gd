extends Node2D

onready var playerScene = preload("res://Scenes/Player.tscn")
onready var opossumScene = preload("res://Scenes/Opossum.tscn")
onready var enemySpawnArray = [get_node("EnemySpawn1"), get_node("EnemySpawn2")]
const spawnRate = 4.0
const maxEnemies = 2
var currentEnemyCount = 0
var canSpawn = true
var timer = null

func _ready():
	enemy_spawn_timer()
	spawn_player()
	

func _process(delta):
	if currentEnemyCount < maxEnemies and canSpawn:
		spawn_enemy(enemySpawnArray[randi()%enemySpawnArray.size()])


func spawn_player():
	var player = playerScene.instance()
	var spawn = get_node("SpawnPoint")
	player.position = Vector2(spawn.position.x, spawn.position.y)
	add_child(player)


func spawn_enemy(spawnPos):
	var enemy = opossumScene.instance()
	enemy.position = Vector2(spawnPos.position.x, spawnPos.position.y)
	add_child(enemy)
	print("spawned enemy")
	currentEnemyCount +=1
	canSpawn = false
	timer.start()


func timer_complete():
	canSpawn = true


func enemy_spawn_timer():
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(spawnRate)
	timer.connect("timeout", self, "timer_complete")
	add_child(timer)