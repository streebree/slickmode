class_name Door extends StaticBody2D

@export var door_name: String

func open():
	call_deferred("queue_free")

func on_key_entered(body: Node2D) -> void:
	if "keys_collected" in body and body.keys_collected.find(door_name) != -1:
		open()
