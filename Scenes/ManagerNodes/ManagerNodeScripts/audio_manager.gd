extends Node2D

var Night
var Castle
var Drum
var Hat
var Player


func _ready() -> void:
	Night = $Music/Night
	Castle = $Music/Castle
	Drum = $Music/Drum
	Hat = $Music/Hat
	Player = get_parent().get_node("Player")

func randomizePitchAndPlay(sfx, min, max):
	var new_pitch = randf_range(min, max)
	sfx.pitch_scale = new_pitch
	sfx.play()


func fadeIn(AudioPlayer, maxVolume, fadeInSpeed):
	AudioPlayer.set_volume_db(move_toward(AudioPlayer.volume_db, maxVolume, fadeInSpeed))

func fadeOut(AudioPlayer, fadeOutSpeed):
	AudioPlayer.set_volume_db(move_toward(AudioPlayer.volume_db, -80, fadeOutSpeed))

func _physics_process(delta: float) -> void:
	if Player:
		if Player.velocity:
			fadeIn(Drum, 0, 5)
		else:
			fadeOut(Drum, 5)
		
		if Player.mode == "Night":
			fadeIn(Night, -5, 1)
			fadeOut(Castle, 0.1)
		else:
			fadeOut(Night, 0.1)
			fadeIn(Castle, 0, 1)
