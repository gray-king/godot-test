extends Area2D

# will be sent when a player hits an enemy
signal hit

@export var speed = 400 # how fast the player will move in px/sec
var screen_size # size of game window

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size 	# find size of game window
	hide() # hide player when game starts

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# set velocity to 0 as player not moving
	var velocity = Vector2.ZERO # player's movement vector
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed # normalise velocity to prevent fast diagonal travel
		$AnimatedSprite2D.play() # play anim. if sprite is moving
	else:
		$AnimatedSprite2D.stop() # no anim. if sprite is still
		
	# clamp position to prevent sprite leaving screen
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	# correct animations for directions
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

# need this since our enemies are RigidBody2D
func _on_body_entered(body: Node2D) -> void:
	hide() # player disappears after being hit
	hit.emit() # send out 'hit' signal
	# only disable collision shape until it is safe to do so by deferring
	$CollisionShape2D.set_deferred("disabled", true)

# reset player when starting a new game
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
