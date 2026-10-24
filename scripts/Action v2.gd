extends Resource
class_name Action

signal info_fetched(attack: AttackInstance)

signal effect_added(effect: Effect)
signal effect_removed(effect: Effect)

@export var name: StringName = &"action"
@export var icon: Texture2D = null
@export_multiline("Tooltip") var tooltip: String = ""
@export var tags: Array[StringName] = []

@export var AOE: bool = false
@export var min_range: int = 0
@export var max_range: int = 2

@export var base_damage: int = 2
@export var power_scaling: float = 0.0 # TODO: proper flexible scaling (speed, power, length, ....) ("hidden"? stats...)

@export var bonus_crit_chance: float = 0.0
@export var bonus_crit_damage: float = 0.0

@export var bonus_status_chance: float = 0.0
@export var affinities: Array[AffinityType] = []
@export var effects: Array[Effect] = [] :
	set(x):
		for effect: Effect in effects:
			if !x.has(effect): remove_effect(effect, true)

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
	attack.damage = base_damage + int(attack.weapon.power * power_scaling)
	
	attack.crit_chance += bonus_crit_chance
	attack.crit_damage += bonus_crit_damage
	attack.status_chance += bonus_status_chance
	
	attack.tags = tags.duplicate()
	
	for t: AffinityType in affinities:
		var a: Affinity = t.affinity.new()
		if attack.affinities.has(a): attack.affinities[a] += 1
		else: attack.affinities.merge({a: 1})
	
	on_info_fetched(attack)
	info_fetched.emit(attack)

func on_start_used(attack: AttackInstance):
	for effect: Effect in effects: effect.on_start_host_used(attack)
func on_used_bake(attack: AttackInstance):
	for effect: Effect in effects: effect.on_host_used_bake(attack)
