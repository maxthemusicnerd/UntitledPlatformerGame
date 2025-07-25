extends CharacterBody2D

const MAX_SPEED = 600.0
const START_SPEED = 200.0
var speed = START_SPEED

const JUMP_HEIGHT = 500

const MAX_GRAVITY = 40
const START_GRAVITY = 20
var grav = START_GRAVITY
var sprite
var is_jumping
var last_time_on_ground

enum STATES { MOBILE, DEAD, WIN}

var state = STATES.MOBILE

#air dash code

var nearEnemy = []
var isDashing
var dashStrenghth = 1000
var airdashtimer


#music code

var mode = "Night"

#game manager stuff
var nextLevelName = ""
var gameManager

func _ready():
	airdashtimer = $airdashtimer
	sprite = $AnimatedSprite2D
	gameManager = get_parent()




func death():
	var level = get_parent().get_node("CurrentLevel").get_child(0)
	var marker = level.get_node("spawnpoint")
	global_position = marker.global_position
	gameManager.respawnEnemies()




func celebrate():
	state = STATES.WIN
	velocity = Vector2.ZERO







var facing_forward = true

func animationHandler(direction):
	
	if not facing_forward:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	if state == STATES.WIN:
		sprite.play("celebrate")
		return
	
	if is_jumping:
		sprite.speed_scale = 1.0
		if sprite.animation != "jump":
			sprite.play("jump")
	else:
		if not direction:
			sprite.play("default")
			sprite.speed_scale = 1.0
		else:
			var animSpeed = abs(velocity.x / (MAX_SPEED / 2))
			sprite.speed_scale = animSpeed
			sprite.play("run")


func randomizePitchAndPlay(sfx, min, max):
	var new_pitch = randf_range(min, max)
	sfx.pitch_scale = new_pitch
	sfx.play()


func _physics_process(delta: float) -> void: 
	#print(Engine.get_frames_per_second())
	var on_floor = false
	if is_on_floor():
		on_floor = true
		last_time_on_ground = Time.get_ticks_msec()
	
	
	if Input.is_action_just_pressed("airdash") and nearEnemy.size() > 0:
		var enemy
		var enemyDist = 10000000
		for entity in nearEnemy:
			var dist = position - entity.position
			dist = sqrt((dist.x ** 2) *  (dist.y ** 2))
			if dist < enemyDist:
				enemy = entity
				enemyDist = dist
		enemy.disableCollision()
		var attackVector = (Vector2(enemy.global_position.x, enemy.global_position.y) - Vector2(global_position.x, global_position.y)).normalized()
		enemy.queue_free()
		attackVector.y *= 1.1
		velocity = attackVector * dashStrenghth
		isDashing = true 
		airdashtimer.start(0.34)
		randomizePitchAndPlay($SFX/dash, 0.95, 1.05)
		
	
	
	if Input.is_action_just_pressed("jump") and (on_floor or (Time.get_ticks_msec() - last_time_on_ground) < 200) and is_jumping == false:
		is_jumping = true
		on_floor = false
		randomizePitchAndPlay($SFX/jump, 0.95, 1.05)
		velocity.y = -JUMP_HEIGHT
	
	if not on_floor:
		velocity.y += grav 
		if Input.is_action_pressed("glide") and velocity.y > 0:
			velocity.y /= 2
		if grav < MAX_GRAVITY:
			grav += 2
	else:
		isDashing= false
		is_jumping = false
		grav = START_GRAVITY
	
	var direction := Input.get_axis("left", "right")
	
	#disable controls if at flag 
	if state == STATES.WIN:
		direction = 0
	
	if direction:
		if direction > 0:
			facing_forward = true
		else:
			facing_forward = false
		if not isDashing:
			velocity.x = direction * speed
		else:
			velocity -= Vector2(10, 10)
		if speed < MAX_SPEED:
			speed += 40
	else:
		velocity.x = move_toward(velocity.x, 0, MAX_SPEED/7)
		speed = START_SPEED
	animationHandler(direction)
	move_and_slide()
	


func _on_airdashtimer_timeout() -> void:
	isDashing = false


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "celebrate":
		get_parent().nextLevel(nextLevelName)
