extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = $"../Player"
@onready var nav: NavigationAgent2D = $NavigationAgent2D

var hp: int = 20
var speed = 150 

func _ready() -> void:
	# Start the walking animation immediately
	animated_sprite.play("walk")

func _physics_process(delta: float) -> void:
	# Keeping this empty for now so we can focus purely on combat testing
	_move_towards_player()
	
# Movement Logic????
func _move_towards_player() -> void:
	set_movement_target(player.position)
	if nav.is_navigation_finished():
		return
		
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav.get_next_path_position()
	
	var new_velocity = current_agent_position.direction_to(next_path_position) * speed
	
	if nav.avoidance_enabled:
		nav.set_velocity(new_velocity)
	else:
		_velocity_computed(new_velocity)
	
	move_and_slide()

func _velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity

func actor_setup():
	await get_tree().physics_frame
	set_movement_target(player.position)

func set_movement_target(movement_target: Vector2):
	nav.target_position = movement_target
	
# --- COMBAT LOGIC ---

# 1. This triggers when the player's weapon swings into the enemy's Hurtbox
func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Make sure the thing hitting us has the "weapon" nametag
	if area.is_in_group("weapon"):
		take_damage(area.global_position)

# 2. This triggers when the enemy's Hitbox touches the player's body
func _on_hitbox_body_entered(body: Node2D) -> void:
	# Make sure the thing we bumped into has the "player" nametag
	if body.is_in_group("player"):
		deal_damage_to_player(body)

func take_damage(attacker_position: Vector2) -> void:
	hp -= 1 
	print("Enemy HP: ", hp)
	
	if hp <= 10:
		speed = 350
		animated_sprite.speed_scale = 2.0
		
	$BonkSound.play()
	animated_sprite.modulate = Color.RED
	
	# Check X (Left / Right)
	if attacker_position.x < global_position.x:
		position.x += 20 # Attacker is left, hop right
	else:
		position.x -= 20 # Attacker is right, hop left

	# Check Y (Up / Down)
	if attacker_position.y < global_position.y:
		position.y += 20 # Attacker is above, hop down
	else:
		position.y -= 20 # Attacker is below, hop up
		
	if hp <= 0:
		print("Enemy Defeated!")
		queue_free() 
	else:
		await get_tree().create_timer(0.15).timeout
		
		animated_sprite.modulate = Color.WHITE

func deal_damage_to_player(player_node: Node2D) -> void:
	# Tells the player script to run its damage function and passes the enemy's position
	if player_node.has_method("take_damage"):
		player_node.take_damage(global_position)
