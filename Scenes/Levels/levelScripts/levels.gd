extends Node2D

var enemyPositionList = []

func _ready():
	for enemy in $enemies.get_children():
		enemyPositionList.append(enemy.global_position)

func killAllEnemies():
	for enemy in $enemies.get_children():
		enemy.queue_free()

func respawnAllEnemies():
	killAllEnemies()
	var enemyScene = preload("res://Scenes/Characters/MrBat.tscn")
	for enemyPosition in enemyPositionList:
		var enemyInstance = enemyScene.instantiate()
		enemyInstance.global_position = enemyPosition
		$enemies.add_child(enemyInstance)
