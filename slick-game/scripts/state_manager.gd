extends Node

var listeners = {}

var health = 3
var maxHealth = 3

var score = 0
var multiplier = 1

var multiplier_drop_cooldown_max = 0.5
var multiplier_drop_cooldown = 0.5

var level_timer = 0.0
var level_has_started = false
var level_has_ended = false
# The amount of time you should be the level in. Used to calculate timer score bonus.
var level_par_time = 60
var level_s_rank = 0
var level_a_rank = 0
var level_b_rank = 0
var level_c_rank = 0

var next_level_name = ""

var score_label = preload("res://scenes/score_text.tscn")

func _process(delta: float) -> void:
	# Lower the multiplier every half second. The half second cooldown
	# is just to avoid spamming updates.
	if multiplier_drop_cooldown > 0:
		multiplier_drop_cooldown -= delta
		if multiplier_drop_cooldown <= 0:
			multiplier -= multiplier_drop_cooldown_max / 50
			if multiplier < 1:
				multiplier = 1
			raise("multiplier_update", multiplier)
			multiplier_drop_cooldown = multiplier_drop_cooldown_max
	if level_has_started:
		level_timer += delta
		raise("level_timer_update", level_timer)
	
	# After you win the level, hitting enter/start will start the next level.
	# This should reset all the variables set during the level.
	if level_has_ended and Input.is_action_just_pressed("start"):
		listeners = {}
		level_has_ended = false
		level_has_started = false
		multiplier = 1.0
		score = 0
		level_timer = 0
		get_tree().change_scene_to_file(next_level_name)

func start_level(par_time, s_rank, a_rank, b_rank, c_rank, next_level):
	level_par_time = par_time
	level_has_started = true
	level_s_rank = s_rank
	level_a_rank = a_rank
	level_b_rank = b_rank
	level_c_rank = c_rank
	next_level_name = next_level
	
func end_level():
	if not level_has_started:
		return
		
	level_has_started = false
	level_has_ended = true
	var time_multiplier = level_par_time / level_timer
	var final_score = time_multiplier * score
	var rank = "D"
	if final_score > level_c_rank:
		rank = "C"
	if final_score > level_b_rank:
		rank = "B"
	if final_score > level_a_rank:
		rank = "A"
	if final_score > level_s_rank:
		rank = "S"
		
	var results = {
		score = score,
		final_score = final_score,
		time_bonus = (time_multiplier * score) - score,
		rank = rank
	}
	raise("level_end", results)

func update_score(amount, position):
	score += amount * multiplier
	raise("score_update", score)
	
	if amount > 0:
		multiplier += 0.1
		raise("multiplier_update", multiplier)
		
		var score_text = score_label.instantiate()
		score_text.score = "%d" % amount
		score_text.position = position
		score_text.position.y -= 15
		call_deferred("add_sibling", score_text)
		await get_tree().create_timer(1.0).timeout

func update_health(amount, delta_x):
	health += amount
	if health > maxHealth:
		health = maxHealth
	if health < 0:
		health = 0
	raise("health_update", health)
	if amount < 0: # If you're taking damage.
		raise("take_damage", delta_x)

func update_multiplier(amount):
	multiplier += amount
	if multiplier < 1:
		multiplier = 1
	raise("multiplier_update", multiplier)
	
# void listen(string event, funcref callback)
# adds a function reference to the list of listeners for the given named event
func listen(event, callback):
	if not listeners.has(event):
		listeners[event] = []
	listeners[event].append(callback)

# void ignore(string event, funcref callback)
# removes a function reference from the list of listeners for the given named event
func ignore(event, callback):
	if listeners.has(event):
		if listeners[event].find(callback):
			listeners[event].erase(callback)

# void raise(string event, object args)
# calls each callback in the list of callbacks in listeners for the given named event, passing args to each
func raise(event, args):
	if listeners.has(event):
		for callback in listeners[event]:
			callback.call(args)
