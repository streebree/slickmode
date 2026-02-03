extends CanvasLayer

@onready var health1: Sprite2D = $health1
@onready var health2: Sprite2D = $health2
@onready var health3: Sprite2D = $health3
@onready var scoreLabel: Label = $ScoreLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StateManager.listen("health_update", Callable(self, "on_health_update"))
	StateManager.listen("score_update", Callable(self, "on_score_update"))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_health_update(value):
	print("health update here", value)
	health1.visible = value > 0
	health2.visible = value > 1
	health3.visible = value > 2
	
func on_score_update(value):
	scoreLabel.text =  "%d pts" % value
