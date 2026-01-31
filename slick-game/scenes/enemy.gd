extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var damage_collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var character_body: CharacterBody2D = $"."

const SPEED = -10.0

var is_dead = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_dead and not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity.x = SPEED
	
	if is_dead:
		sprite.rotation_degrees += 500 * delta
	
	move_and_slide()

func destroy(delta_x):
	if delta_x > 0: 
		velocity.x = 200
	else:
		velocity.x = -200
	velocity.y = -150
	is_dead = true
	
	# When dying, they don't collide with anything.
	character_body.collision_mask = 0

	print("DO THING")
