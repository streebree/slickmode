extends Node

var listeners = {}

var health = 3
var maxHealth = 3

var score = 0
var multiplier = 1

var multiplier_drop_cooldown_max = 0.5
var multiplier_drop_cooldown = 0.5

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

func update_score(amount):
	score += amount * multiplier
	raise("score_update", score)
	
	if amount > 0:
		multiplier += 0.1
		raise("multiplier_update", multiplier)

func update_health(amount, delta_x):
	health += amount
	if health > maxHealth:
		health = maxHealth
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
