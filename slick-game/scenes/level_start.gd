extends Area2D

@export var level_par_time_s: float = 60.0
@export var level_s_rank: float = 3000
@export var level_a_rank: float = 2000
@export var level_b_rank: float = 1000
@export var level_c_rank: float = 500
@export var next_level_name: String = "res://scenes/areas/area.tscn"
@export var level_name: String = "level1"

func on_player_entered(body: Node2D) -> void:
	StateManager.start_level(level_par_time_s, level_s_rank, level_a_rank, level_b_rank, level_c_rank, next_level_name, level_name)
