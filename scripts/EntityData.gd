extends Resource
class_name EntityData

@export var name: String = "Entity"

@export var max_health: int = 30
@export var armor: int = 0

@export var weapon: Weapon

@export var inventory: Array = []

@export var tags: Array[StringName] = []

@export var effects: Array[Effect] = [] :
	set(x):
		for effect: Effect in effects:
			if !x.has(effect): remove_effect(effect, true)

func fetch_data(entity: Entity, meta: bool = true):
	entity.max_health = max_health
	entity.armor = armor
	entity.effects = effects.duplicate(true)
	
	entity.inventory = inventory.duplicate()
	
	entity.tags = tags.duplicate()
	
	if meta:
		entity.name = name

func has_effect_type(type: EffectType) -> bool:
	for effect: Effect in effects: if effect.type == type: return true
	return false

func get_effect(type: EffectType) -> Effect:
	for effect: Effect in effects: if effect.type == type: return effect
	return null

func append_effect(effect: Effect, additive_stacks: bool = true) -> Effect:
	for _effect: Effect in effects: effect.stacks = _effect.on_host_added_effect(effect)
	
	if !has_effect_type(effect.type):
		effects.append(effect)
		effect.host = self
		effect.on_added(self)
	
	elif additive_stacks: get_effect(effect.type).stacks += effect.stacks
	else: get_effect(effect.type).stacks = effect.stacks
	
	return effect

func remove_effect(effect: Effect, manual_array_change: bool = false) -> bool:
	if effects.has(effect):
		if !manual_array_change: effects.erase(effect)
		effect.on_removed(self)
		
		for _effect: Effect in effects: _effect.on_host_removed_effect(effect)
		
		return true
	return false

func remove_effect_type(type: EffectType, manual_array_change: bool = false) -> bool:
	if !has_effect_type(type): return false
	
	var effect: Effect = get_effect(type)
	
	if !manual_array_change: effects.erase(effect)
	effect.on_removed(self)
		
	for _effect: Effect in effects: _effect.on_host_removed_effect(effect)
		
	return true
