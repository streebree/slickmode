extends Area2D
@onready var sprite: Sprite2D = $"Sprite2D"

@export var door_name: String

func _ready() -> void:
	StateManager.listen("player_death", Callable(self, "on_player_death"))

func _on_body_entered(body: Node2D) -> void:
	if body.keys_collected.find(door_name) == -1:
		body.keys_collected.append(door_name)
	sprite.visible = false

func on_player_death(args):
	sprite.visible = true
