extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var damage_collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var character_body: CharacterBody2D = $"."
@onready var die_sound: AudioStreamPlayer2D = $DieSound

var is_dead = false
var rng: RandomNumberGenerator

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	match rng.randi_range(0,2):
		0: sprite.play("idle")
		1: sprite.play("idle_2")
		2: sprite.play("idle_3")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_dead and not is_on_floor():
		velocity += get_gravity() * delta
	
	# When dying, they spin.
	if is_dead:
		sprite.rotation_degrees += 500 * delta
		velocity += get_gravity() * delta * 0.5
	
	move_and_slide()

func destroy(delta_x):
	# When dying, they fly up in the air and to the direction you hit them.
	if delta_x > 0: 
		velocity.x = rng.randi_range(350, 400)
	else:
		velocity.x = rng.randi_range(-350, -400)
	velocity.y = rng.randi_range(-250, -125)
	is_dead = true
	die_sound.play()
	
	StateManager.update_score(50, position)
	
	# When dying, they don't collide with anything.
	character_body.collision_mask = 0

# called by the kill plane if the enemy is out of bounds.
func destroy_self():
	call_deferred("queue_free")
