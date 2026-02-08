extends Node2D

@export var level_name = "level1"
# Set the player's abilities for this level.
func _ready() -> void:
	if level_name == "level1":
		StateManager.raise("give_abilities", {
			has_jacket = false,
			can_dash = true
		})
	elif level_name == "level2":
		StateManager.raise("give_abilities", {
			has_jacket = true,
			can_dash = false
		})
	elif level_name == "level3":
		StateManager.raise("give_abilities", {
			has_jacket = true,
			can_dash = true
		})
	elif level_name == "level4":
		StateManager.raise("give_abilities", {
			has_jacket = true,
			can_dash = true
		})
	elif level_name =="level_end":
		print("ending level")
		StateManager.raise("give_abilities", {
			has_jacket = true,
			can_dash = true,
			disabled = true
		})
