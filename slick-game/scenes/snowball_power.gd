extends Area2D
class_name SnowballPower

@onready var sprite: Sprite2D = $"Sprite2D"
@onready var collider: CollisionShape2D = $CollisionShape2D

signal got_snowball
var is_a_snowball = false

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if not is_a_snowball:
		got_snowball.emit()
		sprite.visible = false
		is_a_snowball = true
