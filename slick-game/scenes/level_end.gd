extends Area2D

func on_player_entered(body: Node2D) -> void:
	StateManager.end_level()
