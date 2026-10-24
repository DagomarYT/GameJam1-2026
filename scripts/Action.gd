extends Resource
class_name Action

signal info_fetched(attack: AttackInstance)

signal effect_added(effect: Effect)
signal effect_removed(effect: Effect)

#TODO: Blind formula: 40 + (60 * (e ** (-x / 2))) See Viktor for more info

# Parent Action class, currently only for Player used actions (TODO?)
# Action resources are stored in maps with filled in stats 'n stuff. (Make sure it inherits right)
# Probs not the best way, but this was just a idea prototype at first, so srry abt that.
# Still need a good way of accessing all of these actions, via Game singleton mayb?

@export var name: StringName = &"Action"
@export_multiline("Tooltip") var tooltip: String = ""
@export var texture: Texture2D

@export var power_type := types.arcane
@export var power: int = 1.0

@export var stamina_cost: int = 1.0
@export var crit_mult: float = 2.0
@export var crit_chance: float = 0.1
@export var accuracy: float = 1.0 #TODO

# TODO: custom stack amount per single status chance application
@export var status_chance: float = 0.0
@export var effects: Array[Effect] = [] :
	set(x):
		for effect: Effect in effects:
			if !x.has(effect): remove_effect(effect, true)

@export var tags: Array[StringName] = []

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

enum status_effects{ # No longer rlly useful
	bleed,
	fire,
	poison,
	decay,
	stun,
	charm,
}

func has_effect_type(type: EffectType) -> bool:
	for effect: Effect in effects: if effect.type == type: return true
	return false

func get_effect(type: EffectType) -> Effect:
	for effect: Effect in effects: if effect.type == type: return effect
	return null

func append_effect(effect: Effect, additive_stacks: bool = true):
	for _effect: Effect in effects: effect.stacks = _effect.on_host_added_effect(effect)
	
	if !has_effect_type(effect.type):
		effects.append(effect)
		effect.host = self
		effect.on_added(self)
		effect_added.emit(effect)
	
	elif additive_stacks: get_effect(effect.type).stacks += effect.stacks
	else: get_effect(effect.type).stacks = effect.stacks

func remove_effect(effect: Effect, manual_array_change: bool = false) -> bool:
	if effects.has(effect):
		if !manual_array_change: effects.erase(effect)
		effect.on_removed(self)
		effect_removed.emit(effect)
		
		for _effect: Effect in effects: _effect.on_host_removed_effect(effect)
		
		return true
	return false

func remove_effect_type(type: EffectType, manual_array_change: bool = false) -> bool:
	if !has_effect_type(type): return false
	
	var effect: Effect = get_effect(type)
	
	if !manual_array_change: effects.erase(effect)
	effect.on_removed(self)
	effect_removed.emit(effect)
		
	for _effect: Effect in effects: _effect.on_host_removed_effect(effect)
		
	return true

func on_info_fetched(attack: AttackInstance): pass

func fetch_info(attack: AttackInstance):
	attack.damage = power
	
	attack.crit_chance += crit_chance
	attack.crit_damage += crit_mult
	attack.status_chance += status_chance
	
	attack.tags = tags.duplicate()
	
	on_info_fetched(attack)
	info_fetched.emit(attack)

func on_start_used(attack: AttackInstance):
	for effect: Effect in effects: effect.on_start_host_used(attack)
	
func on_used_bake(attack: AttackInstance):
	for effect: Effect in effects: effect.on_host_used_bake(attack)
