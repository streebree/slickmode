extends CharacterBody2D
class_name snowman

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var head_hitbox: CollisionShape2D = $"Head Hitbox"
@onready var head_spike_hitbox: CollisionShape2D = $Area2D3/SpikeDamageHitboxHead

const SPEED = 300.0
const JUMP_VELOCITY = -350.0
const SPEED_CAP = 150.0
const EXTRA_DASH_SPEED = 150.0

@export var checkpoint_position = Vector2(0, 0)

var direction = 0
var direction_vertical = 0
var ice_collision_count = 0
var prev_x_velocity = 0
var damage_collision_count = 0

var health = 3
var max_health = 3

var damage_cooldown = 0.0
var damage_cooldown_max = 0.7

var delta_x_from_enemy_hit = 0

var dash_duration = 0.5
var dash_duration_current = 0.0

var dash_cooldown = 0.5
var dash_cooldown_current = 0.0

var is_jumping_off_ice = false
var is_on_ice = false

var keys_collected: Array[String] = []

var previous_health = StateManager.maxHealth

func _ready() -> void:
	StateManager.listen("health_update", Callable(self, "on_health_update"))
	StateManager.listen("take_damage", Callable(self, "on_take_damage"))
	
	sprite.animation_finished.connect(on_animation_finished)

func start_dash(dir):
	dash_duration_current = dash_duration
	if dir == 0:
		if velocity.x > 0:
			velocity.x = SPEED_CAP + EXTRA_DASH_SPEED
			#sprite.rotation_degrees = 30
		elif velocity.x < 0:
			velocity.x = -SPEED_CAP - EXTRA_DASH_SPEED
			#sprite.rotation_degrees = -30
	else:
		velocity.x = (SPEED_CAP + EXTRA_DASH_SPEED) * dir
		#if dir > 0:
			#sprite.rotation_degrees = 30
		#else:
			#sprite.rotation_degrees = -30

func handle_die():
	StateManager.raise("player_death", null)
	keys_collected = []
	position = checkpoint_position
	StateManager.update_health(StateManager.maxHealth, 0)
	sprite.modulate = Color(1, 1, 1)
	damage_cooldown = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Decrease the dash cooldown.
	if dash_cooldown_current > 0:
		dash_cooldown_current -= delta
		
	# Decrease dash time.
	if dash_duration_current > 0:
		dash_duration_current -= delta
		if dash_duration_current <= 0:
			# dash just ended:
			sprite.rotation_degrees = 0
			dash_cooldown_current = dash_cooldown


	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping_off_ice = ice_collision_count > 0
	# Letting go of jump makes you stop moving upward.
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y /= 3.0

	# Handle left/right movement.
	direction = Input.get_axis("ui_left", "ui_right")
	direction_vertical = Input.get_axis("ui_up", "ui_down")
	
	if Input.is_action_just_pressed("run") and dash_cooldown_current <= 0 and dash_duration_current <= 0:
		# dash just started:
		start_dash(direction)
	
	# If you hit a wall and you're on ice or jumping from the ice, bounce off the wall to keep speed.
	if is_on_wall() and (is_jumping_off_ice or ice_collision_count > 0):
		velocity.x = -prev_x_velocity
		
	# Handle basic left/right movement input
	if ice_collision_count == 0:
	#if ice_collision_count == 0 and (is_on_floor() or not is_jumping_off_ice):
		if is_on_floor():
			velocity.x = 0
		elif direction:
			velocity.x += direction * SPEED * delta
		elif is_on_floor():
			velocity.x = move_toward(velocity.x, 0, delta * SPEED)
	
	# If you're dashing, the speed cap is a little higher.
	var current_speed_cap = SPEED_CAP + EXTRA_DASH_SPEED if dash_duration > 0 else SPEED_CAP
	# Cap the speed, but change it slowly.
	if absf(velocity.x) > SPEED_CAP:
		if velocity.x > 0:
			velocity.x = move_toward(velocity.x, SPEED_CAP, delta * 400)
		else:
			velocity.x = move_toward(velocity.x, -SPEED_CAP, delta * 400)
			
	prev_x_velocity = velocity.x
	
	# Handle damage cooldowns:
	if damage_cooldown > 0:
		damage_cooldown -= delta
		if damage_cooldown <= 0:
			sprite.modulate = Color(1, 1, 1)
	
		
	# Handle ducking:
	if direction_vertical > 0:
		head_hitbox.disabled = true
		head_spike_hitbox.disabled = true
	else:
		head_hitbox.disabled = false
		head_spike_hitbox.disabled = false
		
	move_and_slide()
	update_animation()

func update_animation():
	# Handle sprite change when pressing left or right.
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true
		
	# Handle jumping animation
	#if Input.is_action_just_pressed("ui_accept"):
		#sprite.play("jump")
	if velocity.y < 0:
		if sprite.animation != "jump":
			sprite.play("jump")
	elif velocity.y > 0:
		if sprite.animation != "falling":
			sprite.play("falling")
	elif velocity.y == 0 and sprite.animation == "falling":
			if  Input.is_action_pressed("ui_down"):
				sprite.play("duck")
			else:
				sprite.play("landing")
		
	# Handle ducking animation
	if Input.is_action_just_pressed("ui_down"):
		sprite.play("duck")
	elif Input.is_action_just_released("ui_down"):
		sprite.play_backwards("duck")
	elif Input.is_action_pressed("ui_down"):
		return
		
	# Handle left/right movement input
	if (Input.is_action_just_pressed("ui_left") and not Input.is_action_pressed("ui_right")) or (Input.is_action_just_pressed("ui_right") and not Input.is_action_pressed("ui_left")):
			sprite.play("lean")
	if (Input.is_action_just_released("ui_left") and not Input.is_action_pressed("ui_right")) or (Input.is_action_just_released("ui_right") and not Input.is_action_pressed("ui_left")):
		sprite.play_backwards("lean")

func on_animation_finished():
	if not Input.is_anything_pressed():
		sprite.play("idle")
		
	if (sprite.animation == "duck" and not Input.is_action_pressed("ui_down")) or (sprite.animation == "landing"):
		if (Input.is_action_pressed("ui_right")) or (Input.is_action_pressed("ui_left")):
			sprite.play("lean")
	
# Ice physics collision
func _on_area_2d_body_entered(body: Node2D) -> void:
	ice_collision_count += 1
	is_on_ice = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	ice_collision_count -= 1
	if (ice_collision_count == 0):
		is_on_ice = false

# Enemy collision
func _on_area_2d_2_body_entered(body: Node2D) -> void:
	# Only take damage if you're not dashing.
	if dash_duration_current <= 0 and damage_cooldown <= 0:
		delta_x_from_enemy_hit = body.position.x - position.x
		StateManager.update_health(-1, 0)

	else:
		# Else you're dashing so destroy the enemy.
		body.destroy(body.position.x - position.x)
		# If you kill an enemy while dashing, you're dash time gets reset so you can chain them.
		dash_duration_current = dash_duration
		var direction := Input.get_axis("ui_left", "ui_right")
		start_dash(direction)

func _on_area_2d_2_body_exited(body: Node2D) -> void:
	pass
	
func on_take_damage(delta_x):
	damage_cooldown = damage_cooldown_max
	sprite.modulate = Color(0.5, 0, 0, 0.3)
	velocity.y -= 150
	if delta_x > 0:
		velocity.x = -50
	if delta_x < 0:
		velocity.x = 50
	
	if StateManager.health <= 0:
		handle_die()

func on_health_update(health):
	pass
	
#func take_damage(delta_x_from_enemy_hit):
	#health -= 1
	#StateManager.raise("health_update", health)
	#print("health ", health)

func on_spike_damage_enter(body: Node2D) -> void:
	# It's difficult to get the enemy to not damage you while you're stomping it. 
	# Use this hack to check if you're falling down and if the enemy already is dead.
	if ("is_dead" in body and not body.is_dead and velocity.y <= 0) or not "is_dead" in body:
		delta_x_from_enemy_hit = body.position.x - position.x
		if damage_cooldown <= 0:
			#take_damage(delta_x_from_enemy_hit)
			StateManager.update_health(-1, delta_x_from_enemy_hit)

		

func on_stomp_enter(body: Node2D) -> void:
	# if you're moving down, destroy the enemy.
	if velocity.y > 0:
		body.destroy()
		if Input.is_action_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY - 30
		else:
			velocity.y = JUMP_VELOCITY / 3
		

func on_collide_with_one_way_down(body: Node2D) -> void:
	if velocity.y < 0:
		velocity.y = 0


func on_enter_one_way_right_only(body: Node2D) -> void:
	if velocity.x < 0:
		velocity.x = -velocity.x
