extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var spike_damage_collision: CollisionShape2D = $"Spike Damage Collision/CollisionShape2D"
@onready var stomp_collision: CollisionShape2D = $"Stomp Collision/CollisionShape2D"
@onready var stomp_collision_area: Area2D = $"Stomp Collision"
@onready var bounce_sound: AudioStreamPlayer2D = $BounceSound

@export var comes_back = false

var is_dead = false
var is_recovering = false
var health = 5

func _ready() -> void:
	sprite.animation_finished.connect(on_animation_finished)

func _physics_process(delta: float) -> void:
	if not is_dead:
		if not is_on_floor():
			velocity += get_gravity() * delta

	move_and_slide()
	update_animation()
	
func update_animation():
	if is_dead and not is_recovering:
		sprite.play("squished")
	if is_dead and is_recovering and sprite.animation == "squished":
		sprite.play("shake_it_off")
	if not is_dead and not is_recovering and sprite.animation == "shake_it_off":
		sprite.play("recover")

func on_animation_finished():
	if sprite.animation == "recover":
		sprite.play("idle")

func destroy():
	is_dead = true
	#sprite.scale = Vector2(1.5, 0.3)
	#sprite.offset.y = 40
	#stomp_collision.disabled = true
	#spike_damage_collision.disabled = true
	
	#stomp_collision_area.collision_mask = 0
	#stomp_collision_area.collision_layer = 0
	
	bounce_sound.play(0.05)
	# disable collisions while dead.
	self.collision_layer = 0
	
	if not comes_back:
		StateManager.update_score(100, position)
		delete_self()
	else:
		# if it comes back, re-enable collision normal size.
		StateManager.update_score(30, position)
		await get_tree().create_timer(1.5).timeout
		is_recovering = true
		await get_tree().create_timer(1.5).timeout
		is_dead = false
		is_recovering = false
		#sprite.scale = Vector2(1, 1)
		#sprite.offset.y = 0
		self.collision_layer = 112
		
		# This was code for the boss version of the enemy:
		#if health == 3:
			#sprite.modulate = Color(0.3, 0.15, 0.0)
		#
		#if health == 1:
			#sprite.modulate = Color(0.5, 0.1, 0.0)
		#
		#health -= 1
		#if health == 1:
			#comes_back = false
	
func delete_self():
	await get_tree().create_timer(0.3).timeout
	call_deferred("queue_free")
	
# called by the kill plane if the enemy is out of bounds.
func destroy_self():
	call_deferred("queue_free")
