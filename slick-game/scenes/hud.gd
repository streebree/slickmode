extends CanvasLayer

@onready var health1: Sprite2D = $health1
@onready var health2: Sprite2D = $health2
@onready var health3: Sprite2D = $health3
@onready var scoreLabel: Label = $ScoreLabel
@onready var multiplierLabel: Label = $MultiplierLabel
@onready var timerLabel: Label = $TimerLabel
@onready var levelResultsLabel: Label = $LevelResultsLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StateManager.listen("health_update", Callable(self, "on_health_update"))
	StateManager.listen("score_update", Callable(self, "on_score_update"))
	StateManager.listen("multiplier_update", Callable(self, "on_multiplier_update"))
	StateManager.listen("level_timer_update", Callable(self, "on_level_timer_update"))
	StateManager.listen("level_end", Callable(self, "on_level_end"))
	# also set the health when the scene first loads since you might
	# be starting with less health from last level.
	on_health_update(StateManager.health)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_health_update(value):
	health1.visible = value > 0
	health2.visible = value > 1
	health3.visible = value > 2
	
func on_score_update(value):
	scoreLabel.text =  "%d pts" % value

func on_multiplier_update(value):
	multiplierLabel.text =  "x %0.2f" % value
	
func on_level_timer_update(value):
	var minutes = value / 60
	var seconds = fmod(value, 60)
	var milliseconds = fmod(value, 1) * 100

	timerLabel.text = "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
	
func on_level_end(results):
	print("got results:", results.score, " ", results.time_bonus)
	levelResultsLabel.text = "YOU WIN!\nScore: %0.0f\nTime bonus: %0.0f\nFINAL SCORE: %0.0f\nRank: %s" % [results.score, results.time_bonus, results.final_score, results.rank]
