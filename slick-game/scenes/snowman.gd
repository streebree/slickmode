extends CharacterBody2D
class_name snowman

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var head_hitbox: CollisionShape2D = $"Head Hitbox"
@onready var head_spike_hitbox: CollisionShape2D = $Area2D3/SpikeDamageHitboxHead
@onready var tilemap: TileMapLayer = %TileMapLayer
@onready var camera: Camera2D = $Camera2D

@onready var sprite_marker: Marker2D = $AnimatedSprite2D/SpriteMarker
@onready var scarf_link: Line2D = $ScarfLink
@onready var scarf: Scarf = $ScarfEnd
@onready var farcast_head: RayCast2D = $AnimatedSprite2D/FarCastHead
@onready var shortcast_head: RayCast2D = $AnimatedSprite2D/ShortCastHead
@onready var farcast_body: RayCast2D = $AnimatedSprite2D/FarCastBody
@onready var shortcast_body: RayCast2D = $AnimatedSprite2D/ShortCastBody
@onready var farcast_scarf: RayCast2D = $AnimatedSprite2D/FarCastScarf
@onready var shortcast_scarf: RayCast2D = $AnimatedSprite2D/ShortCastScarf

@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var damage_sound: AudioStreamPlayer2D = $DamageSound
@onready var land_sound: AudioStreamPlayer2D = $LandSound
@onready var dash_sound: AudioStreamPlayer2D = $DashSound
@onready var bounce_sound: AudioStreamPlayer2D = $BounceSound
@onready var duck_sound: AudioStreamPlayer2D = $DuckSound


const SPEED = 300.0
const JUMP_VELOCITY = -320.0
const SPEED_CAP = 150.0
const EXTRA_DASH_SPEED = 150.0

@export var looking_direction = 1
@export var checkpoint_position = Vector2(0, 0)
@export var has_jacket = false
@export var can_dash = false

var is_player = true
var is_player_on_floor = true

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

var dash_duration = 0.3
var dash_duration_current = 0.0

var dash_cooldown = 0.3
var dash_cooldown_current = 0.0

var is_jumping_off_ice = false
var is_on_ice = false
var is_ducked_under_tile = false

var keys_collected: Array[String] = []

var previous_health = StateManager.maxHealth
var was_in_air_last_frame = false

var has_ground_pounded = false
var has_double_jumped = false
var is_double_jumping = false
var target_velocity = 0
var time_double_jumping = 0
var double_jump_length = 1.0

var in_wind_count = 0

var is_scarf_started = false
var is_in_hit_shake = false
var shake_origin_position = null
var shake_frames = 3
var shake_counter = 0
var stomp_y = 0

func _ready() -> void:
	StateManager.listen("health_update", Callable(self, "on_health_update"))
	StateManager.listen("take_damage", Callable(self, "on_take_damage"))
	StateManager.listen("give_abilities", Callable(self, "on_give_abilities"))
	sprite.animation_finished.connect(on_animation_finished)
	
	#scarf_link.points = [Vector2.ZERO, Vector2.ZERO]
	#scarf.hit_something.connect(on_scarf_hit)
	scarf.visible = false
	scarf_link.visible = false
	
#func start_scarf_throw():
	#is_scarf_started = true
	#sprite.stop()
	#sprite.play("scarf_startup")
	## Start throw after startup is finished in on_animation_finished

#func update_scarflink():
	#var start = scarf_link.to_local(sprite_marker.global_position)
	#var end = scarf_link.to_local(scarf.marker.global_position)
	#scarf_link.points = [
		#start,
		#end
	#]
	#
	#if end.x < start.x:  # Make sure the texture is facing the correct way
		##scarf_link.texture_mode = Line2D.LINE_TEXTURE_TILEd 
		#scarf_link.scale.y = -1
	#else:
		#scarf_link.scale.y = 1

#func on_scarf_hit(direction):
	#print("on_scarf_hit")
	#
	#is_in_hit_shake = true
	#shake_origin_position = position
	#await get_tree().create_timer(0.3).timeout
	#
	#start_dash(direction)
	#sprite.play("scarf_return")
	

func start_dash(direction):
	if not can_dash:
		return
	
	dash_sound.play(0.35)
	dash_duration_current = dash_duration
	is_scarf_started = false
	
	if direction == 0:
		if looking_direction > 0:
			velocity.x = SPEED_CAP + EXTRA_DASH_SPEED
			#sprite.rotation_degrees = 30
		else:
			velocity.x = -SPEED_CAP - EXTRA_DASH_SPEED
			#sprite.rotation_degrees = -30
	else:
		velocity.x = (SPEED_CAP + EXTRA_DASH_SPEED) * direction
		#if dir > 0:
			#sprite.rotation_degrees = 30
		#else:
			#sprite.rotation_degrees = -30
	# Should it affect your y velocity in some way?
	#velocity.y = 0
	sprite.modulate = Color(1, 0, 0, 1)

func handle_die():
	StateManager.raise("player_death", null)
	#is_scarf_started = false
	# for now, when you die, you keep your keys
	#keys_collected = []
	position = checkpoint_position
	velocity = Vector2(0, 0)
	StateManager.update_health(StateManager.maxHealth, 0)
	sprite.modulate = Color(1, 1, 1)
	damage_cooldown = 0

func _physics_process(delta: float) -> void:
	if StateManager.level_has_ended:
		velocity.x = 0
		velocity.y = 0
		move_and_slide()
		return
		
	# Update scarf link during animation
	#if scarf.is_thrown:
		#update_scarflink()
		#scarf_link.visible = true
		#
		#if is_in_hit_shake:
			#if shake_counter < shake_frames + 1:
				#shake_counter += 1
				#match shake_counter:
					#1: position.x = shake_origin_position.x + 5 * looking_direction
					#2: position.x = shake_origin_position.x - 3 * looking_direction
					#3: position.x = shake_origin_position.x + 1 * looking_direction
					#4: 
						#position = shake_origin_position
						#
						#print("hello")
						#is_in_hit_shake = false
						#shake_counter = 0
						#shake_origin_position = null
	#else:
		#scarf_link.visible = false
		
	# Add the gravity.
	if not is_on_floor(): #and not scarf.is_thrown
		var multiplier = 0.8
		# If you're falling and you're holding jump, do a slower fall.
		if velocity.y > 0:
			if Input.is_action_pressed("ui_accept"):
				multiplier = 0.6
			# if you're holding down, do a fast fall
			elif Input.is_action_pressed("ui_down"):
				multiplier = 1
		if not is_double_jumping: 
			velocity += get_gravity() * multiplier * delta
		if velocity.y > 500:
			velocity.y = 500
		
		if Input.is_action_just_pressed("ui_down") and not has_ground_pounded:
			velocity.y += 100
			has_ground_pounded = true
		
	# Decrease the dash cooldown.
	if dash_cooldown_current > 0:
		dash_cooldown_current -= delta
		if dash_cooldown_current <= 0:
			sprite.modulate = Color(1, 1, 1)
		
	# Decrease dash time.
	if dash_duration_current > 0:
		dash_duration_current -= delta
		if dash_duration_current <= 0:
			# dash just ended:
			sprite.rotation_degrees = 0
			dash_cooldown_current = dash_cooldown
			sprite.modulate = Color(0, 1, 1, 0.3)

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		#if scarf.is_thrown:
			#scarf.cancel_scarf()
			#return
		
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			is_jumping_off_ice = ice_collision_count > 0
			jump_sound.play()
	if not is_on_floor() and has_jacket and Input.is_action_just_pressed("double_jump") and not has_double_jumped:
		#target_velocity = -velocity.y
		target_velocity = -(velocity.y * 1.1)
		if target_velocity > 100:
			target_velocity = 200
			velocity.y = 2000 # I don't know why, but this make the first part of the double jump feel nicer
		has_double_jumped = true
		is_double_jumping = true
		time_double_jumping = 0
	
	if is_double_jumping:
		time_double_jumping += delta
		if Input.is_action_pressed("double_jump"):
			if time_double_jumping > double_jump_length:
				is_double_jumping = false
				stomp_y = 0
			else:
				var distance = (time_double_jumping / double_jump_length) * 2 * absf(target_velocity)
				velocity.y = move_toward(-target_velocity, target_velocity, distance)
				# This stomp_y hack is a way to make the stomp bounce still work 
				# while you're hovering. The above line overwrites the normal stomp
				# velocity, so add it in but quickly taper it back down.
				if stomp_y != 0:
					velocity.y += stomp_y
					stomp_y /= 1.1

		else:
			is_double_jumping = false
			
	# Handle wind physics. If you're holding jump, get extra height.
	if in_wind_count > 0 and not is_on_floor():
		if Input.is_action_pressed("ui_accept"):
			velocity.y -= 1000 * delta
			# Speed cap your vertical speed in the wind, or it gets a little crazy.
			# Consider taking this out though, if it feels good.
			if velocity.y < -300:
				velocity.y = -300
		else:
			velocity.y -= 500 * delta
		
	# Letting go of jump makes you stop moving upward.
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y /= 3.0
		
	# Reset your midair abilities when landing:
	if was_in_air_last_frame and is_on_floor():
		land_sound.play(0.05)
		has_ground_pounded = false
		has_double_jumped = false
		is_double_jumping = false
		was_in_air_last_frame = false
		
	# Handle left/right movement.
	direction = Input.get_axis("ui_left", "ui_right")
	#print("hello direction: ", direction)
	
	# Remember which direction you're looking for dash calculations
	if absf(direction) != 0:
		looking_direction = direction
		#if not is_scarf_started or not scarf.is_thrown:
			#looking_direction = direction # Once scarf is started lock your looking direction
			#
		#shortcast_head.target_position.x = 24.0 * looking_direction
		#shortcast_scarf.target_position.x = 24.0 * looking_direction
		#shortcast_body.target_position.x = 24.0 * looking_direction
		#
		#farcast_head.target_position.x = 74.0 * looking_direction
		#farcast_scarf.target_position.x = 74.0 * looking_direction
		#farcast_body.target_position.x = 74.0 * looking_direction
		
	direction_vertical = Input.get_axis("ui_up", "ui_down")
	
	if Input.is_action_just_pressed("run") and not is_scarf_started and dash_cooldown_current <= 0 and dash_duration_current <= 0:
		# dash just started:
		start_dash(direction)
		#start_scarf_throw()
	
	# If you hit a wall and you're on ice or jumping from the ice, bounce off the wall to keep speed.
	if is_on_wall() and (is_jumping_off_ice or ice_collision_count > 0):
		#scarf.reset()
		velocity.x = -prev_x_velocity
		bounce_sound.play(0.06)
		
	# Handle basic left/right movement input
	if ice_collision_count == 0 and not scarf.is_thrown:
		if is_on_floor():
			velocity.x = 0
		elif direction:
			velocity.x += direction * SPEED * delta
		#elif is_on_floor():
			#velocity.x = move_toward(velocity.x, 0, delta * SPEED)
	
	# If you're dashing, the speed cap is a little higher.
	var current_speed_cap = SPEED_CAP + EXTRA_DASH_SPEED if dash_duration > 0 else SPEED_CAP
	# Cap the speed, but change it slowly.
	if absf(velocity.x) > SPEED_CAP:
		if velocity.x > 0:
			velocity.x = move_toward(velocity.x, SPEED_CAP, delta * 400)
		else:
			velocity.x = move_toward(velocity.x, -SPEED_CAP, delta * 400)
	
			
	# Set some values about this frame so the next frame can compare how the state changed.
	prev_x_velocity = velocity.x
	if not is_on_floor():
		was_in_air_last_frame = true
	is_player_on_floor = is_on_floor()
	
	
	
	# Handle damage cooldowns:
	if damage_cooldown > 0:
		damage_cooldown -= delta
		if damage_cooldown <= 0:
			sprite.modulate = Color(1, 1, 1)
	
		
	# Handle ducking:
	if not is_ducked_under_tile:
		if direction_vertical > 0:
			head_hitbox.disabled = true
			head_spike_hitbox.disabled = true
		else:
			head_hitbox.disabled = false
			head_spike_hitbox.disabled = false
	else: # override normal behavior to force player to stay ducked
		head_hitbox.disabled = true
		head_spike_hitbox.disabled = true
		
	move_and_slide()
	check_above_tile()
	update_animation()
	#queue_redraw()

func update_animation():
	# Handle sprite change when pressing left or right.
	if looking_direction > 0:
		sprite.flip_h = false
	elif looking_direction < 0:
		sprite.flip_h = true
		
	if scarf.is_thrown or sprite.animation == "scarf_startup":
		return
		
	if not is_ducked_under_tile:
		# Handle jumping animation
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
					
		# Handle dashing animation
		if not sprite.animation == "duck":
			if abs(velocity.x) > 175:
				sprite.play("dash")
				sprite.stop()
				sprite.frame = 0
			elif abs(velocity.x) <= 175 and abs(velocity.x) > 160:
				sprite.play("dash")
				sprite.stop()
				sprite.frame = 1
			elif abs(velocity.x) <= 160 and abs(velocity.x) > 150:
				sprite.play("dash")
				sprite.stop()
				sprite.frame = 2
		
	# Handle ducking animation
	if Input.is_action_just_pressed("ui_down"):
		duck_sound.play(.2)
		sprite.play("duck")
	elif Input.is_action_just_released("ui_down"):
			if not is_ducked_under_tile:
				sprite.play_backwards("duck")
			else:
				return
	elif Input.is_action_pressed("ui_down"):
		if sprite.animation == "dash" and is_player_on_floor: # To handle ducking when landing out of a dash
			sprite.play("duck")
		return # return regardless so that the lean is not triggered when player should be ducking
	elif not Input.is_anything_pressed() and not is_ducked_under_tile and sprite.animation == "duck":
		sprite.play_backwards("duck")
		
	# Handle left/right movement input on ground
	if is_player_on_floor:
		if (Input.is_action_just_pressed("ui_left") and not Input.is_action_pressed("ui_right")) or (Input.is_action_just_pressed("ui_right") and not Input.is_action_pressed("ui_left")):
				if not sprite.animation == "dash":
					sprite.play("lean")
				else:
					sprite.frame = 2 # the last frame of dash is the same as the last frame of lean
		if (Input.is_action_just_released("ui_left") and not Input.is_action_pressed("ui_right")) or (Input.is_action_just_released("ui_right") and not Input.is_action_pressed("ui_left")):
			sprite.play_backwards("lean")

func on_animation_finished():
	#if sprite.animation == "scarf_startup":
		#if not check_shortcast():
			#scarf.throw(looking_direction)
			#sprite.play("scarf_idle")
			#
			#velocity.x *= 0.5 
			#velocity.y = 0
		#else:
			#sprite.play("scarf_return")
			#is_scarf_started = false
		#
	#if scarf.is_thrown:
		#return
	
	if not Input.is_anything_pressed() or sprite.animation == "scarf_return":
		if is_ducked_under_tile:
			return
		elif sprite.animation == "duck":
			sprite.play_backwards("duck")
		
		if velocity.y == 0 and sprite.animation != "idle":
			sprite.play("idle")
		
	if (sprite.animation == "duck" and not Input.is_action_pressed("ui_down")) or (sprite.animation == "landing"):
		if (Input.is_action_pressed("ui_right")) or (Input.is_action_pressed("ui_left")):
			sprite.play("lean")
			
func check_above_tile() -> bool:
	if tilemap == null:
		return false
	var head_tile_pos = tilemap.local_to_map(global_position)
	var head_tile_data = tilemap.get_cell_tile_data(head_tile_pos)
	
	if head_tile_data and not head_tile_data.get_custom_data("is_deadly"):
		is_ducked_under_tile = true
	else:
		is_ducked_under_tile = false
	return head_tile_data == null

#func check_shortcast() -> bool:
	#return shortcast_head.is_colliding() or shortcast_body.is_colliding() or shortcast_scarf.is_colliding()
	#
#func get_farcast():
	#var closest_collision_point = null
	#var closest_distance = INF
	#
	#if farcast_head.is_colliding() or farcast_body.is_colliding() or farcast_scarf.is_colliding():
		#if farcast_head.is_colliding():
			#if farcast_head.position.distance_to(to_local(farcast_head.get_collision_point())) < closest_distance:
				#closest_collision_point = to_local(farcast_head.get_collision_point())
				#closest_distance = farcast_head.position.distance_to(to_local(farcast_head.get_collision_point()))
		#
		#if farcast_scarf.is_colliding():
			#if farcast_scarf.position.distance_to(to_local(farcast_scarf.get_collision_point())) < closest_distance:
				#closest_collision_point = to_local(farcast_scarf.get_collision_point())
				#closest_distance = farcast_scarf.position.distance_to(to_local(farcast_scarf.get_collision_point()))
				#
		#if farcast_body.is_colliding():
			#if farcast_body.position.distance_to(to_local(farcast_body.get_collision_point())) < closest_distance:
				#closest_collision_point = to_local(farcast_body.get_collision_point())
				#closest_distance = farcast_body.position.distance_to(to_local(farcast_body.get_collision_point()))
#
	#return { "point": closest_collision_point, "distance": closest_distance - 24.0 } # Remove offset

#func _draw():
		## Draw where the head collision would be
		#draw_circle(shortcast_head.target_position, 5, Color.RED if  shortcast_head.is_colliding() or shortcast_body.is_colliding() or shortcast_scarf.is_colliding()  else Color.GREEN)
		#draw_circle(shortcast_body.target_position, 5, Color.RED if  shortcast_head.is_colliding() or shortcast_body.is_colliding() or shortcast_scarf.is_colliding() else Color.GREEN)
		#
		#draw_circle(farcast_body.target_position, 5, Color.RED if  farcast_body.is_colliding() or farcast_head.is_colliding() or farcast_scarf.is_colliding() else Color.BLUE)
		#draw_circle(farcast_head.target_position, 5, Color.RED if  farcast_body.is_colliding() or farcast_head.is_colliding() or farcast_scarf.is_colliding() else Color.BLUE)
		#
		#if shortcast_head.is_colliding() or shortcast_body.is_colliding() or shortcast_scarf.is_colliding():
			#var closest_collision_point = null
			#if shortcast_head.position.distance_to(to_local(shortcast_head.get_collision_point())) < shortcast_head.position.distance_to(to_local(shortcast_body.get_collision_point())):
				#closest_collision_point = to_local(shortcast_head.get_collision_point())
			#else:
				#closest_collision_point = to_local(shortcast_body.get_collision_point())
			#
			#draw_circle(closest_collision_point, 5, Color.LIGHT_GREEN)
			#
		#if farcast_head.is_colliding() or farcast_body.is_colliding() or farcast_scarf.is_colliding():
			##print(shortcast.get_collider())
			#var closest_collision_point = null
			#var closest_distance = INF
			#if farcast_head.is_colliding():
				##print("far head: ", farcast_head.get_collider())
				#if farcast_head.position.distance_to(to_local(farcast_head.get_collision_point())) < closest_distance:
					#closest_collision_point = to_local(farcast_head.get_collision_point())
					#closest_distance = farcast_head.position.distance_to(to_local(farcast_head.get_collision_point()))
			#
			#if farcast_scarf.is_colliding():
				##print("far scarf: ", farcast_scarf.get_collider())
				#if farcast_scarf.position.distance_to(to_local(farcast_scarf.get_collision_point())) < closest_distance:
					#closest_collision_point = to_local(farcast_scarf.get_collision_point())
					#closest_distance = farcast_scarf.position.distance_to(to_local(farcast_scarf.get_collision_point()))
					#
			#if farcast_body.is_colliding():
				##print("far body: ", farcast_body.get_collider())
				#if farcast_body.position.distance_to(to_local(farcast_body.get_collision_point())) < closest_distance:
					#closest_collision_point = to_local(farcast_body.get_collision_point())
					#closest_distance = farcast_body.position.distance_to(to_local(farcast_body.get_collision_point()))
			#
			#draw_circle(closest_collision_point, 5, Color.SKY_BLUE)

func destroy_self():
	StateManager.update_health(-100, 0)
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
	print(body)
	# Only take damage if you're not dashing.
	if dash_duration_current <= 0:
		if damage_cooldown <= 0:
			delta_x_from_enemy_hit = body.position.x - position.x
			StateManager.update_health(-1, delta_x_from_enemy_hit)
			damage_sound.play()
	else:
		# Else you're dashing so destroy the enemy.
		body.destroy(body.position.x - position.x)
		# If you kill an enemy while dashing, you're dash time gets reset so you can chain them.
		dash_duration_current = dash_duration
		direction = Input.get_axis("ui_left", "ui_right")
		start_dash(direction)

func _on_area_2d_2_body_exited(body: Node2D) -> void:
	pass

# Key door collision

func on_take_damage(delta_x):
	StateManager.update_multiplier(-1)
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
	
func on_give_abilities(abilities):
	has_jacket = abilities.has_jacket
	can_dash = abilities.can_dash
	
#func take_damage(delta_x_from_enemy_hit):
	#health -= 1
	#StateManager.raise("health_update", health)
	#print("health ", health)

func on_spike_damage_enter(body: Node2D) -> void:
	# It's difficult to get the enemy to not damage you while you're stomping it. 
	# Use this hack to check if you're falling down and if the enemy already is dead.
	if ("is_dead" in body and not body.is_dead) or not "is_dead" in body:
	# If there are issues with the stomp collision after this change, consider changing 
	# it back to this:
	#if ("is_dead" in body and not body.is_dead and velocity.y <= 0) or not "is_dead" in body:
		delta_x_from_enemy_hit = body.position.x - position.x
		if damage_cooldown <= 0:
			#take_damage(delta_x_from_enemy_hit)
			StateManager.update_health(-1, delta_x_from_enemy_hit)
			damage_sound.play()
			

func on_stomp_enter(body: Node2D) -> void:
	# if you're moving down, destroy the enemy.
	if velocity.y > 0:
		body.destroy()
		has_double_jumped = false
		
		if Input.is_action_pressed("ui_accept"):
			stomp_y = JUMP_VELOCITY - 30
			velocity.y = JUMP_VELOCITY - 30
		else:
			stomp_y = JUMP_VELOCITY / 2
			velocity.y = JUMP_VELOCITY / 2
		

func on_collide_with_one_way_down(body: Node2D) -> void:
	if velocity.y < 0:
		velocity.y = 0


func on_enter_one_way_right_only(body: Node2D) -> void:
	if velocity.x < 0:
		velocity.x = -velocity.x


func on_one_way_left_collision(body: Node2D) -> void:
	if velocity.x > 0:
		velocity.x = -velocity.x


func on_enter_wind(body: Node2D) -> void:
	in_wind_count += 1
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "zoom", Vector2(1, 1), 0.8)

func on_exit_wind(body: Node2D) -> void:
	in_wind_count -= 1
	# Leaving the wind gives you a refreshed double jump.
	if in_wind_count == 0:
		has_double_jumped = false
