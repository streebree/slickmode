extends Label

var fade_time_current = -10
var fade_time = 2

var has_faded_in = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if has_faded_in:
		fade_time_current -= delta
	else:
		fade_time_current += delta
		
	if fade_time_current > fade_time:
		has_faded_in = true
		
	modulate.a = clamp(fade_time_current / fade_time, 0, 1)
