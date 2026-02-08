extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StateManager.listen("start_second_level_song", Callable(self, "on_start_second_level_song"))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_start_second_level_song(args):
	play()
