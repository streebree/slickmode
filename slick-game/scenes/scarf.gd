extends Area2D
class_name Scarf

signal hit_something

@onready var raycast: RayCast2D = $RayCast2D
@onready var marker: Marker2D = $ScarfEndMarker
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: snowman = $".."

var starting_position
var hit_position
var is_thrown = false
var has_hit = false
var canceled = false

var throw_direction = 0

const THROW_SPEED = 500.0
const MAX_THROW_DISTANCE = 50.0

func _ready() -> void:
    sprite.animation_finished.connect(on_animation_finished)

func throw(direction):
    throw_direction = direction
    raycast.position.x += 24 * throw_direction
    raycast.target_position = Vector2(30 * throw_direction, 0)
    global_position = Vector2(player.global_position.x + 24 * throw_direction, player.global_position.y + 1)
    
    visible = true
    is_thrown = true
    has_hit = false
    starting_position = global_position
    
func reset():
    is_thrown = false
    has_hit = false
    visible = false
    top_level = false
    canceled = false

    hit_position = null
    starting_position = null
 
func _process(delta: float) -> void:
    if is_thrown and not has_hit:
        if(raycast.is_colliding()):
            has_hit = true
        else:
            position.x += THROW_SPEED * throw_direction * delta
            if global_position.distance_to(starting_position) >= MAX_THROW_DISTANCE:
                has_hit = true
        
    if has_hit:
        hit_position = global_position
        top_level = true
        global_position = hit_position
    
    if canceled:
        #top_level = false
        if hit_position:
            global_position = hit_position
            global_position.x -= THROW_SPEED * throw_direction * delta
        else:
            position.x -= THROW_SPEED * throw_direction * delta
        
    if has_hit or canceled:
        if global_position.distance_to(player.global_position) < 20:
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
        
        if has_hit and sprite.animation != "hit":
            hit_something.emit(throw_direction)
            sprite.play("hit")
            
func on_animation_finished():
    pass
     #if sprite.animation == "return":
        #reset()

func cancel_scarf():
    is_thrown = false
    has_hit = false
    canceled = true
    sprite.play("return")

func on_scarf_area2d_entered(body: Node2D) -> void:
    print("Hello entered body: ", body)
    if is_thrown:
        has_hit = true
