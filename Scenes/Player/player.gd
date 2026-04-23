extends CharacterBody2D
@onready var left: Sprite2D = $left
@onready var right: Sprite2D = $right


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
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

	if Input.is_action_pressed("ui_left"):
		left.visible = true
		right.visible = false
	elif Input.is_action_pressed("ui_right"):
		left.visible = false
		right.visible = true
	move_and_slide()
