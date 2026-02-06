extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction = 1
var is_dead = false

func _ready() -> void:
	velocity.x = direction * 100
	velocity.y = 0
	StateManager.listen("player_death", Callable(self, "on_player_death"))

func _process(delta: float) -> void:
	if not is_dead:
		sprite.rotation_degrees -= delta * 1000
	if is_on_wall() or is_on_floor():
		destroy()
	move_and_slide()
	
func destroy():
	is_dead = true
	collision_layer = 0
	collision_mask = 0
	sprite.play()
	delete_self()

func delete_self():
	await get_tree().create_timer(0.4).timeout
	StateManager.ignore("player_death", Callable(self, "on_player_death"))
	call_deferred("queue_free")
	
# called by the kill plane if the enemy is out of bounds.
func destroy_self():
	StateManager.ignore("player_death", Callable(self, "on_player_death"))
	call_deferred("queue_free")

func on_player_death(args):
	destroy_self()
