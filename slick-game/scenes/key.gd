extends Area2D

@export var door_name: String

func _on_body_entered(body: Node2D) -> void:
	print("key_body eneterd")
	body.keys_collected.append(door_name)
	call_deferred("queue_free")
