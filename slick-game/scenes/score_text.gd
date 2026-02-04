extends Node2D

@onready var label = $Label
@export var score = ""

func _ready() -> void:
	label.text = score
	await get_tree().create_timer(1.0).timeout
	call_deferred("queue_free")

func _process(delta: float) -> void:
	label.text = score
	position.y -= delta * 20
	label.modulate.a -= delta
