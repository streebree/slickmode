extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var spike_damage_collision: CollisionShape2D = $"Spike Damage Collision/CollisionShape2D"
@onready var stomp_collision: CollisionShape2D = $"Stomp Collision/CollisionShape2D"
@onready var stomp_collision_area: Area2D = $"Stomp Collision"

var is_dead = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
	
func destroy():
	is_dead = true
	sprite.scale = Vector2(1.5, 0.3)
	sprite.offset.y = 40
	stomp_collision.disabled = true
	spike_damage_collision.disabled = true
	
	stomp_collision_area.collision_mask = 0
	print("Destroy Spiky Enemy")
	stomp_collision_area.collision_layer = 0
	
	self.collision_layer = 0
	
	delete_self()
	
func delete_self():
	await get_tree().create_timer(0.3).timeout
	call_deferred("queue_free")
