extends Node
class_name Player

@export var max_health: int = 20
@onready var health: int = max_health :
	set(x):
		health = clampi(x, 0, max_health)

@export var max_stamina: int = 20
@onready var stamina: int = max_stamina :
	set(x):
		health = clampi(x, 0, max_stamina)

#TODO: held weapons (dual-wielding, two-handing, one hand empty, ...)
@export var attacks: Array[Attack] = [] # Should be (max) 2 (according to held weapons)
@export var spells: Array[Spell] = [] # For now should be max 3-4, something like that.

func _ready() -> void: Game.player = self

func rand_loadout():
	pass #TODO: random loadout generator & setup for player
