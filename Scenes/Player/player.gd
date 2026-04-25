extends CharacterBody2D

# --- NODES ---
@onready var left: Sprite2D = $left
@onready var right: Sprite2D = $right

@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var weapon_sprite: AnimatedSprite2D = $WeaponPivot/WeaponArea/WeaponSprite
@onready var weapon_hitbox: CollisionShape2D = $WeaponPivot/WeaponArea/WeaponHitbox

# --- STATS ---
const SPEED = 300.0
var lives: int = 4
var is_attacking: bool = false

func _ready() -> void:
	# Hide weapon and disable hitbox on startup
	weapon_sprite.hide()
	weapon_hitbox.disabled = true
	
	# Connect signals for the active frames logic
	weapon_sprite.animation_finished.connect(_on_attack_finished)
	weapon_sprite.frame_changed.connect(_on_weapon_frame_changed)

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

# --- WEAPON LOGIC ---

func perform_attack() -> void:
	is_attacking = true
	weapon_sprite.show()
	weapon_sprite.play("swing") 

func _on_attack_finished() -> void:
	is_attacking = false
	weapon_sprite.hide()
	weapon_sprite.stop()
	weapon_hitbox.disabled = true

func _on_weapon_frame_changed() -> void:
	if not is_attacking:
		return
		
	# Turns the damage hitbox ON during frames 3, 4, and 5
	if weapon_sprite.frame >= 3 and weapon_sprite.frame <= 5:
		weapon_hitbox.disabled = false
	else:
		weapon_hitbox.disabled = true

# --- TAKING DAMAGE LOGIC ---

func take_damage(attacker_position: Vector2) -> void:
	lives -= 1
	print("Player hit! Lives remaining: ", lives)
	
	# --- SIMPLE X/Y INSTANT HOP (KNOCKBACK) ---
	
	# Check X (Left / Right)
	if attacker_position.x < global_position.x:
		position.x += 30 # Enemy is left, hop right
	else:
		position.x -= 30 # Enemy is right, hop left

	# Check Y (Up / Down)
	if attacker_position.y < global_position.y:
		position.y += 30 # Enemy is above, hop down
	else:
		position.y -= 30 # Enemy is below, hop up
		
	if lives <= 0:
		print("Game Over!")
