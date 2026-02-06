extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var height = 0
var is_dead = false
var sway = 0



func _physics_process(delta: float) -> void:
	height += delta * 3
	if height > 10000:
		height = 0
		
	if is_dead:
		position.y += delta * 100 + (sin(height) / 4)
		position.x += sin(sway)
		sway += delta * 10
	else:
		position.y += sin(height) / 4
	move_and_slide()

func destroy():
	sprite.pause()
	sprite.rotation_degrees = 180
	is_dead = true
	collision_layer = 0
	collision_mask = 0
	StateManager.update_score(100, position)
	delete_self()
	
func delete_self():
	await get_tree().create_timer(3.0).timeout
	call_deferred("queue_free")
	
# called by the kill plane if the enemy is out of bounds.
func destroy_self():
	call_deferred("queue_free")
