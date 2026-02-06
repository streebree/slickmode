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
	
	# this is a hacky way to turn back on collision by setting the bits:
	# 3 means 1 and 2 are set.
	collision_layer = 3
	collision_mask = 3
	if tween != null:
		tween.kill()
		tween.free()
		tween = null
	sprite.modulate = Color(1, 1, 1, 1)
	has_fallen = false
	

func _process(delta: float) -> void:
	pass
	# sometimes if you die before the platform is destroyed, the position
	# won't reset so this makes sure it resets.
	#if !has_fallen:
		#position = initial_position
		#sprite.modulate = Color(1, 1, 1, 1)
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if !has_fallen and "is_player" in body and body.is_player_on_floor:
		sprite.modulate = Color(0, 0, 0.5)
		has_fallen = true
		await get_tree().create_timer(0.5).timeout
		collision_layer = 0
		collision_mask = 0
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
		#tween.tween_property(self, "global_position", global_position + Vector2 (0, 200), 1.0)

	
		
