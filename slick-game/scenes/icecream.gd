extends Area2D

@onready var collect_sound: AudioStreamPlayer2D = $CollectSound
@onready var sprite_2d: Sprite2D = $Sprite2D
var is_collected = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
		
	StateManager.update_health(1, 0)
	StateManager.update_score(200, position)
	collect_sound.play()
	sprite_2d.modulate = Color(0, 0, 0, 0)
	
	is_collected = true
	await get_tree().create_timer(1.5).timeout
	
	call_deferred("queue_free")
