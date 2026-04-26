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
var is_dashing: bool = false 

func _ready() -> void:
	weapon_sprite.hide()
	weapon_hitbox.disabled = true
	
	weapon_sprite.animation_finished.connect(_on_attack_finished)
	weapon_sprite.frame_changed.connect(_on_weapon_frame_changed)

func _physics_process(delta: float) -> void:
	if not is_attacking:
		if Input.is_action_just_pressed("ui_accept") and not is_dashing:
			$DashSound.play()
			perform_dash()

		var active_speed = SPEED
		if is_dashing:
			active_speed = SPEED * 3.0 

		# --- MOVEMENT ---
		var altitude := Input.get_axis("ui_up", "ui_down")
		if altitude:
			velocity.y = altitude * active_speed
		else:
			velocity.y = move_toward(velocity.y, 0, active_speed)

		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * active_speed
		else:
			velocity.x = move_toward(velocity.x, 0, active_speed)

		# --- FACING DIRECTION ---
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
			$SwingSound.play()
			perform_attack()
			
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	move_and_slide()

# --- DASH LOGIC ---

func perform_dash() -> void:
	is_dashing = true
	
	# The code pauses here for exactly 0.2 seconds while the player zooms away
	await get_tree().create_timer(0.2).timeout
	
	# After 0.2 seconds, turn the dash off so speed goes back to normal
	is_dashing = false

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
		
	if weapon_sprite.frame >= 3 and weapon_sprite.frame <= 5:
		weapon_hitbox.disabled = false
	else:
		weapon_hitbox.disabled = true

# --- TAKING DAMAGE LOGIC ---

func take_damage(attacker_position: Vector2) -> void:
	lives -= 1
	print("Player hit! Lives remaining: ", lives)
	
	$HurtSound.play()
	
	var life_bar = get_tree().get_first_node_in_group("lifebar")
	if life_bar:
		life_bar.value = lives
	
	# Simple X/Y Instant Hop Knockback
	if attacker_position.x < global_position.x:
		position.x += 40 
	else:
		position.x -= 40 

	if attacker_position.y < global_position.y:
		position.y += 40 
	else:
		position.y -= 40 
		
	if lives == 0:
		$HurtGameOverSound.play()
		handle_death()

func handle_death() -> void:
	print("Player Died!")
	
	# 1. Stop all player script physics and input
	process_mode = PROCESS_MODE_DISABLED 
	
	var game_over_node = get_node("/root/Node2D/UI/GameOverScreen")
	if game_over_node:
		game_over_node.show() # Shows the semi-transparent overlay
