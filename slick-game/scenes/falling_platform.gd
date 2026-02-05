extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite2D
var has_fallen = false
var initial_position = Vector2(0, 0)

var tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gravity_scale = 0
	StateManager.listen("player_death", Callable(self, "on_player_death"))
	initial_position = position

func on_player_death(args):
	position = initial_position
	collision_layer = 1
	collision_mask = 1
	has_fallen = false
	sprite.modulate = Color(1, 1, 1)
	if tween != null:
		tween.kill()
		tween.free()
		tween = null
	

func _process(delta: float) -> void:
	# sometimes if you die before the platform is destroyed, the position
	# won't reset so this makes sure it resets.
	if !has_fallen:
		position = initial_position
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if !has_fallen and "is_player" in body and body.is_player_on_floor:
		sprite.modulate = Color(0, 0, 0.5)
		has_fallen = true
		await get_tree().create_timer(0.5).timeout
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "global_position", global_position + Vector2 (0, 200), 1.0)
		tween.tween_property(sprite, "opacity", 0, 0.1)
		collision_layer = 0
		collision_mask = 0
	
		
