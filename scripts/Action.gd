extends Resource
class_name Action

#TODO: Blind formula: 40 + (60 * (e ** (-x / 2))) See Viktor for more info

# Parent Action class, currently only for Player used actions (TODO?)
# Action resources are stored in maps with filled in stats 'n stuff. (Make sure it inherits right)
# Probs not the best way, but this was just a idea prototype at first, so srry abt that.
# Still need a good way of accessing all of these actions, via Game singleton mayb?


@export var name: StringName = &"Action"
@export var texture: Texture2D

@export var power_type := types.arcane
@export var power: int = 1.0

@export var stamina_cost: int = 1.0
@export var crit_mult: float = 2.0
@export var crit_chance: float = 0.1
@export var accuracy: float = 1.0

@export var status_chance: float = 0.0
@export var effect: Dictionary[effects, int] = {}

@export var Tags: Array[StringName] = []

enum types{
	fire,
	arcane,
	cursed,
	holy,
	healing,
	slash,
	pierce,
	impact,
}

enum effects{
	bleed,
	fire,
	poison,
	decay,
	stun,
	charm,
}
