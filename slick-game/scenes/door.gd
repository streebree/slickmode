class_name Door extends StaticBody2D

@export var door_name: String
@onready var sprite: Sprite2D = $"Sprite2D"

#func on_ready():
	#StateManager.listen("player_death", Callable(self, "on_player_death"))
	
func open():
	call_deferred("queue_free")
	#sprite.visible = false

func on_key_entered(body: Node2D) -> void:
	if "keys_collected" in body and body.keys_collected.find(door_name) != -1:
		open()

#func on_player_death():
	#sprite.visible = true
