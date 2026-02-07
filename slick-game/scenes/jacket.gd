extends Area2D
class_name Jacket

@onready var sprite: Sprite2D = $"Sprite2D"
@onready var collider: CollisionShape2D = $CollisionShape2D

signal got_jacket
var is_wearing_jacket = false

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if not is_wearing_jacket:
		got_jacket.emit()
		sprite.visible = false
		is_wearing_jacket = true
