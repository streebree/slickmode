extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if "checkpoint_position" in body:
		body.checkpoint_position = position
		
