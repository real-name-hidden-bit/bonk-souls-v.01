extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Just play the animation so it looks alive
	animated_sprite.play("walk")

func _physics_process(delta: float) -> void:
	# AI Chasing logic is removed for now!
	pass

# --- COMBAT LOGIC ---

# 1. This triggers when the player's weapon swings into the enemy's Hurtbox
func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Check if the thing that hit us has the "weapon" nametag
	if area.is_in_group("weapon"):
		take_damage()

# 2. This triggers when the enemy's Hitbox touches the player's body
func _on_hitbox_body_entered(body: Node2D) -> void:
	# Check if the thing we bumped into has the "player" nametag
	if body.is_in_group("player"):
		deal_damage_to_player(body)

func take_damage() -> void:
	# For now, the enemy is destroyed instantly
	print("Enemy got BONKED!")
	queue_free() 

func deal_damage_to_player(player_node: Node2D) -> void:
	# Tells the player script to run its damage function
	if player_node.has_method("take_damage"):
		player_node.take_damage()
