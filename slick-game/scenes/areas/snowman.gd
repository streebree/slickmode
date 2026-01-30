extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -300.0
const SPEED_CAP = 150.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Letting go of jump makes you stop moving upward.
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y /= 3.0

	# Handle left/right movement.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x += direction * SPEED * delta
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, delta * SPEED)
	
	# Cap the speed.
	if absf(velocity.x) > SPEED_CAP:
		if velocity.x > 0:
			velocity.x = SPEED_CAP
		else:
			velocity.x = -SPEED_CAP

	move_and_slide()
