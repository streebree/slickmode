extends Area2D
@onready var sprite: Sprite2D = $"Sprite2D"

@export var door_name: String
@onready var collect_sound: AudioStreamPlayer2D = $CollectSound

var is_collected = false

func _ready() -> void:
	StateManager.listen("player_death", Callable(self, "on_player_death"))

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body.keys_collected.find(door_name) == -1:
		body.keys_collected.append(door_name)
		collect_sound.play()
		is_collected = true
	sprite.visible = false

func on_player_death(args):
	pass
	#sprite.visible = true
