extends Area2D
@onready var end_sound: AudioStreamPlayer2D = $EndSound

func on_player_entered(body: Node2D) -> void:
	end_sound.play()
	StateManager.end_level()
