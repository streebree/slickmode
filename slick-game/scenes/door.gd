class_name Door extends RigidBody2D

@export var door_name: String
@onready var sprite: AnimatedSprite2D = $"AnimatedSprite2D"
@onready var key_legend: AnimatedSprite2D = $"KeyLegend"
# Need to reference how many keys the player is holding so that we can update the sprite(s)
@onready var open_sound_2: AudioStreamPlayer2D = $OpenSound2
@onready var open_sound: AudioStreamPlayer2D = $OpenSound

var is_unlocked = false

func on_ready():
	sprite.animation_finished.connect(on_animation_finished)
	#StateManager.listen("player_death", Callable(self, "on_player_death"))
	
func open():
	key_legend.visible = false
	open_sound_2.play()
	open_sound.play()
	
	is_unlocked = true
	sprite.play("unlock")
	StateManager.update_score(50, position)
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	var rng = RandomNumberGenerator.new()
	linear_velocity.x *= rng.randi_range(100, 200)
	linear_velocity.y += rng.randi_range(-100, -200)
	angular_velocity += 50 * sign(linear_velocity.x)
	await get_tree().create_timer(2).timeout
	call_deferred("queue_free")
	#sprite.visible = false

func on_key_entered(body: Node2D) -> void:
	if "keys_collected" in body and body.keys_collected.find(door_name) != -1:
		open()
	else:
		sprite.play("bump")

func on_animation_finished():
	sprite.play("default")
	
#func on_player_death():
	#sprite.visible = true
