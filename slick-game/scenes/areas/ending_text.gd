extends CanvasLayer
@onready var label: Label = $Label

var fade_time_current = 0
var fade_time = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fade_time_current += delta
	label.modulate.a = max(fade_time_current / fade_time, 1)
