extends Area2D
class_name Scarf

signal hit_something


@onready var marker: Marker2D = $ScarfEndMarker
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var snowman: snowman = $".."

var starting_position
var hit_position
var is_thrown = false
var is_throw_done = false
var has_hit = false
var canceled = false

var throw_direction = 0.0

const THROW_SPEED = 500.0
const MAX_THROW_DISTANCE = 50.0

func _ready() -> void:
	sprite.animation_finished.connect(on_animation_finished)

func throw(direction):
	throw_direction = direction
	global_position = Vector2(snowman.global_position.x + 24.0 * throw_direction, snowman.global_position.y + 1)
	
	snowman.update_scarflink()
	
	visible = true
	is_thrown = true
	has_hit = false
	starting_position = global_position
	
func reset():
	is_thrown = false
	is_throw_done = false
	has_hit = false
	visible = false
	top_level = false
	canceled = false

	hit_position = null
	starting_position = null
 
func _process(delta: float) -> void:
	if is_thrown and not has_hit:
		var prev_position: Vector2 = global_position
		var farcast_collision = snowman.get_farcast()
		var new_max_distance = farcast_collision["distance"] if farcast_collision else INF
		
		var next_position = position.x + THROW_SPEED * throw_direction * delta
		if global_position.distance_to(Vector2(next_position, global_position.y)) <= global_position.distance_to(Vector2(new_max_distance, global_position.y)):
			position.x = next_position
		else:
			position.x = farcast_collision["point"].x
			
		if global_position.distance_to(starting_position) >= (MAX_THROW_DISTANCE if MAX_THROW_DISTANCE < new_max_distance else new_max_distance):
			has_hit = true
			
		if prev_position == global_position: # If the scarf gets stuck on a wall corner, consider it a hit
			has_hit = true
		
	if has_hit:
		hit_position = global_position
		top_level = true
		global_position = hit_position
		
		if not is_throw_done:
			hit_something.emit(throw_direction)
			is_throw_done = true
			
	if global_position.distance_to(snowman.global_position) < 20:
		print("resetting")
		reset()
	
	update_animation()

func update_animation():	
	if not has_hit:
		if throw_direction < 0:
			sprite.flip_h = true
		elif throw_direction > 0:
			sprite.flip_h = false
	
	if is_thrown:
		if not has_hit and sprite.animation != "moving":
			sprite.play("moving")
		
		if has_hit:
			if sprite.animation != "hit":
				sprite.play("hit")
			
func on_animation_finished():
	pass


func cancel_scarf():
	reset()
