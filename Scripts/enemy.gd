extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var hp: int = 50

func _ready() -> void:
	# Start the walking animation immediately
	animated_sprite.play("walk")

func _physics_process(delta: float) -> void:
	# Keeping this empty for now so we can focus purely on combat testing
	pass

# --- COMBAT LOGIC ---

# 1. This triggers when the player's weapon swings into the enemy's Hurtbox
func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Make sure the thing hitting us has the "weapon" nametag
	if area.is_in_group("weapon"):
		# Using area.global_position prevents the 'owner' crash!
		take_damage(area.global_position)

# 2. This triggers when the enemy's Hitbox touches the player's body
func _on_hitbox_body_entered(body: Node2D) -> void:
	# Make sure the thing we bumped into has the "player" nametag
	if body.is_in_group("player"):
		deal_damage_to_player(body)

func take_damage(attacker_position: Vector2) -> void:
	hp -= 1 
	print("Enemy HP: ", hp)
	
	# --- SIMPLE X/Y INSTANT HOP (KNOCKBACK) ---
	
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

func deal_damage_to_player(player_node: Node2D) -> void:
	# Tells the player script to run its damage function and passes the enemy's position
	if player_node.has_method("take_damage"):
		player_node.take_damage(global_position)
