extends Node

var listeners = {}

#var health = 3
#var maxHealth = 3
#
#func damage_player(points: int):
	#health -= points

# void listen(string event, funcref callback)
# adds a function reference to the list of listeners for the given named event
func listen(event, callback):
	print("listen for ", event)
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
