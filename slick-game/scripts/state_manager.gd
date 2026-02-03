extends Node

var listeners = {}

var health = 3
var maxHealth = 3

var score = 0

func update_score(delta):
	score += delta
	raise("score_update", score)

func update_health(delta, delta_x):
	health += delta
	if health > maxHealth:
		health = maxHealth
	raise("health_update", health)
	if delta < 0: # If you're taking damage.
		raise("take_damage", delta_x)
	
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
