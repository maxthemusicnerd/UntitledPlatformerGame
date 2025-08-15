extends Node2D

var Player
var CurrentLevel
var AudioManager

func _ready():
	Player = $Player
	CurrentLevel = $CurrentLevel
	AudioManager = $AudioManager
	Player.global_position = CurrentLevel.get_child(0).get_node("spawnpoint").global_position


func nextLevel(newLevelName):
	#Delete Current Level
	CurrentLevel.get_child(0).queue_free()
	
	var newLevel = load("res://Scenes/Levels/" + newLevelName + ".tscn")
	newLevel = newLevel.instantiate()
	CurrentLevel.add_child(newLevel)
	var playerStartPosition = newLevel.get_node("spawnpoint").global_position
	Player.global_position = playerStartPosition
	Player.state = Player.STATES.MOBILE




func respawnEnemies():
	CurrentLevel.get_child(0).respawnAllEnemies()
