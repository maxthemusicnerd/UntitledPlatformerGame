extends CharacterBody2D

const MAX_SPEED = 600.0
const START_SPEED = 200.0
var speed = START_SPEED

const JUMP_HEIGHT = 530

const MAX_GRAVITY = 40
const START_GRAVITY = 20
var grav = START_GRAVITY
var sprite
var is_jumping = false
var last_time_on_ground




enum STATES { MOBILE, DEAD, WIN}

var state = STATES.MOBILE

#air dash code

var nearEnemy = []
var isDashing
#dash strength is normally 1000
var dashStrenghth = 1200
var airdashtimer


#walljump and slide code
var wallSlideDecrement := 1.0
var canWallJump := false
var isWallJumping := false 

@onready var rightchecker = $WalljumpColliders/rightchecker
@onready var leftchecker = $WalljumpColliders/leftchecker



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
	
	if not isWallJumping:
		if not facing_forward:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	
	
	if state == STATES.WIN:
		sprite.play("celebrate")
		return
	
	if canWallJump:
		sprite.play("cling")
		return
	
	if isWallJumping:
		sprite.play("walljump")
		if canWallJump:
			sprite.play("cling")
			if not facing_forward:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			return
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


#input buffering 
var timeSinceAirdashPress: float = 1
var timeSinceJumpPress: float = 1


func _physics_process(delta: float) -> void: 
	#print(Engine.get_frames_per_second())
	var on_floor = false
	if is_on_floor():
		on_floor = true
		last_time_on_ground = Time.get_ticks_msec()
	
	
	timeSinceAirdashPress += delta
	timeSinceJumpPress += delta
	
	if Input.is_action_just_pressed("airdash"):
		timeSinceAirdashPress = 0 
	
	if Input.is_action_just_pressed("jump"):
		timeSinceJumpPress = 0
	
	
	if timeSinceAirdashPress < 0.1 and nearEnemy.size() > 0:
		timeSinceAirdashPress += 1
		var enemy
		var enemyDist = 10000000
		for entity in nearEnemy:
			var dist = position - entity.position
			dist = sqrt((dist.x ** 2) *  (dist.y ** 2))
			if dist < enemyDist:
				enemy = entity
				enemyDist = dist
		if enemy:
			enemy.disableCollision()
			#vector to enemy averaged with joystick input vector normalized 
			#var attackVector = Input.get_vector("left", "right", "up", "down")
			var attackVector = ((((Vector2(enemy.global_position.x, enemy.global_position.y) - Vector2(global_position.x, global_position.y)).normalized()) + Input.get_vector("left", "right", "up", "down")) / 2).normalized()
			enemy.queue_free()
			attackVector.y *= 1.1
			velocity = attackVector * dashStrenghth
			isDashing = true 
			airdashtimer.start(0.34)
			randomizePitchAndPlay($SFX/dash, 0.95, 1.05)
		
	
	
	if Input.is_action_just_pressed("jump") and canWallJump and not on_floor:
		isWallJumping = true 
		canWallJump = false
		velocity.y = -JUMP_HEIGHT * 1.2
		if facing_forward:
			velocity.x = -800
		else:
			velocity.x = 800
		randomizePitchAndPlay($SFX/walljump, 0.8, 0.9)
		airdashtimer.start(0.3)
		 
	
	
	if timeSinceJumpPress < 0.1 and (on_floor or (Time.get_ticks_msec() - last_time_on_ground) < 200) and is_jumping == false:
		timeSinceJumpPress += 1
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
		isDashing = false
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
		if not isDashing and not isWallJumping:
			velocity.x = direction * speed
		else:
			velocity -= Vector2(10, 10)
		if speed < MAX_SPEED:
			speed += 20
		
		if (rightchecker.is_colliding() and direction > 0) or (leftchecker.is_colliding() and direction < 0):
			if not on_floor:
				canWallJump = true
			if velocity.y >= 0:
				wallSlideDecrement += delta
				velocity.y /= wallSlideDecrement 
		else:
			canWallJump = false
			wallSlideDecrement = 1.0
			pass
	else:
		velocity.x = move_toward(velocity.x, 0, MAX_SPEED/7)
		speed = START_SPEED
		canWallJump = false
	animationHandler(direction)
	move_and_slide()
	

func _on_airdashtimer_timeout() -> void:
	isDashing = false
	isWallJumping = false


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "celebrate":
		get_parent().nextLevel(nextLevelName)
	if sprite.animation == "walljump":
		isWallJumping = false
