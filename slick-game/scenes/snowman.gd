extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -300.0
const SPEED_CAP = 150.0

var ice_collision_count = 0
var prev_x_velocity = 0
var damage_collision_count = 0

var health = 3

var delta_x = 0

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
	if ice_collision_count > 0:
		if is_on_wall():
			velocity.x = -prev_x_velocity
	elif direction:
		velocity.x += direction * SPEED * delta
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, delta * SPEED)
	
	# Cap the speed
	if absf(velocity.x) > SPEED_CAP:
		if velocity.x > 0:
			velocity.x = SPEED_CAP
		else:
			velocity.x = -SPEED_CAP
			
	prev_x_velocity  = velocity.x
	
	# Handle damage:
	if damage_collision_count > 0:
		health -= 1
		velocity.y -= 150
		if delta_x > 0:
			velocity.x -= 200
		if delta_x < 0:
			velocity.x += 200
		damage_collision_count = 0
		print("health", health)
			
	
	move_and_slide()
	


# Ice physics collision
func _on_area_2d_body_entered(body: Node2D) -> void:
	ice_collision_count += 1

func _on_area_2d_body_exited(body: Node2D) -> void:
	ice_collision_count -= 1

# Enemy collision
func _on_area_2d_2_body_entered(body: Node2D) -> void:
	print("GET HIT")
	delta_x = body.position.x - position.x
	damage_collision_count += 1

func _on_area_2d_2_body_exited(body: Node2D) -> void:
	pass
	# damage_collision_count -= 1
