extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var height = 0
var is_dead = false
var sway = 0
var shoot_cooldown = 2.0
var shoot_cooldown_current = 2.0

var direction = -1

var player = null

var snowball = preload("res://scenes/snowball.tscn")

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
		
	if shoot_cooldown_current > 0:
		shoot_cooldown_current -= delta
	if player != null and shoot_cooldown_current <= 0:
		shoot()
		shoot_cooldown_current = shoot_cooldown
	
	if player != null:
		if player.position < position:
			direction = -1
			sprite.flip_h = false
		else:
			direction = 1
			sprite.flip_h = true
	move_and_slide()

func shoot():
	var newSnowball = snowball.instantiate()
	newSnowball.position = position
	if direction < 0:
		newSnowball.position.x -= 20
	else:
		newSnowball.position.x += 20
	newSnowball.direction = direction
	call_deferred("add_sibling", newSnowball)
	
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

func on_see_player(body: Node2D) -> void:
	if "is_player" in body:
		player = body
	


func on_player_leave(body: Node2D) -> void:
	if "is_player" in body:
		player = null
	
