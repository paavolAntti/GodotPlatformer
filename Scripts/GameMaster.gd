extends Node2D

onready var playerScene = preload("res://Scenes/Player.tscn")

func _ready():
	var player = playerScene.instance()
	var spawn = get_node("SpawnPoint")
	player.position = Vector2(spawn.position.x, spawn.position.y)
	
	add_child(player)


