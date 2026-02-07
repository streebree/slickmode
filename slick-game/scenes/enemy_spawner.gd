extends Node2D

@export var enemy: PackedScene = preload("res://scenes/enemy.tscn")
var spawned_enemy = null

#@onready var debug_sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	#debug_sprite.visible = false
	spawn_enemy()
	StateManager.listen("player_death", Callable(self, "on_player_death"))

func on_player_death(args):
	if (spawned_enemy != null and spawned_enemy.is_dead) or spawned_enemy == null:
		spawn_enemy()

func spawn_enemy():
	spawned_enemy = enemy.instantiate()
	spawned_enemy.position = position
	call_deferred("add_sibling", spawned_enemy)
	
