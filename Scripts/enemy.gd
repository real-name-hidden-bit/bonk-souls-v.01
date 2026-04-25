extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# We will adjust this later when making it chase the player
const SPEED = 100.0 

func _ready() -> void:
	# Start the walking animation immediately when the enemy spawns
	animated_sprite.play("walk")

func _physics_process(delta: float) -> void:
	# --- CHASE LOGIC WILL GO HERE LATER ---
	
	# Flips the sprite so the eye always looks in the direction it is moving
	if velocity.x < 0:
		animated_sprite.flip_h = true
	elif velocity.x > 0:
		animated_sprite.flip_h = false

	move_and_slide()

# --- PREPARING FOR COMBAT ---
# We will connect the Area2D signals to these functions in the next step!

func take_damage() -> void:
	# Code for when the player's weapon hits the enemy's Hurtbox
	pass

func deal_damage_to_player() -> void:
	# Code for when the enemy's Hitbox touches the player
	pass
