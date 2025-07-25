extends Node2D

var Player
var CurrentLevel
var AudioManager

func _ready():
	Player = $Player
	CurrentLevel = $CurrentLevel
	AudioManager = $AudioManager
	Player.position = CurrentLevel.get_child(0).get_node("spawnpoint").position


func nextLevel(newLevelName):
	#Delete Current Level
	CurrentLevel.get_child(0).queue_free()
	
	var newLevel = load("res://Scenes/Levels/" + newLevelName + ".tscn")
	newLevel = newLevel.instantiate()
	CurrentLevel.add_child(newLevel)
	var playerStartPosition = newLevel.get_node("spawnpoint").position
	Player.position = playerStartPosition
	Player.state = Player.STATES.MOBILE




func respawnEnemies():
	CurrentLevel.get_child(0).respawnAllEnemies()
