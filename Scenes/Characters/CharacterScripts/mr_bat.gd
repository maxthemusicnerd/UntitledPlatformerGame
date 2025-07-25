extends CharacterBody2D

var Player

var playerInside = false

const SPEED = 50

var Arrow

func _ready():
	Arrow = $arrow
	Player = get_parent().get_parent().get_parent().get_parent().get_node("Player")


func randomizePitchAndPlay(sfx, min, max):
	var new_pitch = randf_range(min, max)
	sfx.pitch_scale = new_pitch
	sfx.play()



func _physics_process(delta: float) -> void:
	if playerInside and Player:
		var direction = (Player.global_position - global_position).normalized()
		velocity = direction * SPEED
		manageArrowPosition()
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func disableCollision():
	$hitbox/CollisionShape2D.disabled = true 
	$Collider.disabled = true


func manageArrowPosition():
	var differenceVector = Player.global_position - global_position
	Arrow.position = differenceVector / 2
	Arrow.rotation = differenceVector.angle() + PI



func _on_sweetspot_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		randomizePitchAndPlay($SFX/lockOn, 0.98, 1.02)
		body.nearEnemy.append(self)
		playerInside = true 
		Arrow.visible = true


func _on_sweetspot_body_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		body.nearEnemy.erase(self)
		playerInside = false
		Arrow.visible = false


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		body.death()
