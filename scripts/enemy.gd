extends Node
class_name Enemy

@export var max_health: int = 20
@onready var health: int = max_health :
	set(x):
		health = maxi(x, 0)

@export var actions: Array[Action] = [] # TODO: possible actions and processing.



@export var Tags: Array[StringName] = []
# Placeholder-ish way to declare special properties.
# Each property would need to be hardcoded this way though. (it's just a gamejam though, so, yeah...

func act():
	pass
