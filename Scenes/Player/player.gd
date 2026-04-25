extends CharacterBody2D

# Existing Player Sprites
@onready var left: Sprite2D = $left
@onready var right: Sprite2D = $right

# Weapon References
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var weapon_sprite: AnimatedSprite2D = $WeaponPivot/WeaponArea/WeaponSprite
@onready var weapon_hitbox: CollisionShape2D = $WeaponPivot/WeaponArea/WeaponHitbox

const SPEED = 300.0
var lives: int = 4

# State Variable
var is_attacking: bool = false

func _ready() -> void:
	# Hide weapon and disable hitbox on startup
	weapon_sprite.hide()
	weapon_hitbox.disabled = true
	
	# Connect signals so the code knows when animations change or finish
	weapon_sprite.animation_finished.connect(_on_attack_finished)
	weapon_sprite.frame_changed.connect(_on_weapon_frame_changed) # NEW SIGNAL HERE

func _physics_process(delta: float) -> void:
	# Only allow movement and aiming if the player is NOT currently attacking
	if not is_attacking:
		var altitude := Input.get_axis("ui_up", "ui_down")
		if altitude:
			velocity.y = altitude * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)

		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		# --- FACING DIRECTION (Player Sprites) ---
		if Input.is_action_pressed("ui_left"):
			left.visible = true
			right.visible = false
		elif Input.is_action_pressed("ui_right"):
			left.visible = false
			right.visible = true
			
		# --- AIMING THE WEAPON ---
		var input_dir := Vector2(direction, altitude)
		if input_dir != Vector2.ZERO:
			weapon_pivot.rotation = input_dir.angle()
			
		# --- TRIGGER ATTACK ---
		if Input.is_action_just_pressed("attack"): 
			perform_attack()
			
	else:
		# If the player is attacking, stop their momentum quickly
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()

func perform_attack() -> void:
	is_attacking = true
	
	# Show the sprite and play the animation
	weapon_sprite.show()
	weapon_sprite.play("swing") 
	
	# Notice we NO LONGER enable the hitbox here!
	# The frame_changed function will handle it now.

func _on_attack_finished() -> void:
	# Reset back to normal movement state
	is_attacking = false
	
	weapon_sprite.hide()
	weapon_sprite.stop()
	weapon_hitbox.disabled = true


func _on_weapon_frame_changed() -> void:
	if not is_attacking:
		return
		
	if weapon_sprite.frame >= 3 and weapon_sprite.frame <= 5:
		weapon_hitbox.disabled = false
	else:
		weapon_hitbox.disabled = true 
		
func take_damage() -> void:
	lives -= 1
	print("Player hit! Lives remaining: ", lives)
	
	if lives <= 0:
		print("Game Over!")
		# Later, you can reload the scene or show a Game Over screen here
		# get_tree().reload_current_scene()
