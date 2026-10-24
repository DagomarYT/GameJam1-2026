extends Resource
class_name Entity

signal effect_added(effect: Effect)
signal effect_removed(effect: Effect)

signal damage_attempted(cause: Resource, _tags: Array[StringName])
signal damage_received(cause: Resource, amount: int, _tags: Array[StringName])
signal health_changed(amount: int)

@export var name: String = "Entity"

@export var data: EntityData = null :
	set(x):
		if !data: x.fetch_data(self)
		data = x

var max_health: int = 30
var health: int = max_health :
	set(x):
		if x != health: health_changed.emit(x - health)
		health = x
		print(str("health: ", health))

@export var tags: Array[StringName] = []
# Placeholder-ish way to declare special properties.
# Each property would need to be hardcoded this way though. (it's just a gamejam though, so, yeah...

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

func append_effect(effect: Effect, additive_stacks: bool = true) -> Effect:
	for _effect: Effect in effects: effect.stacks = _effect.on_host_added_effect(effect)
	
	if !has_effect_type(effect.type):
		effects.append(effect)
		effect.host = self
		effect.on_added(self)
		effect_added.emit(effect)
	
	elif additive_stacks: get_effect(effect.type).stacks += effect.stacks
	else: get_effect(effect.type).stacks = effect.stacks
	
	return effect

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

func on_start_turn() -> void:
	for effect: Effect in effects: effect.on_host_start_turn()
	
func on_end_turn() -> void:
	for effect: Effect in effects: effect.on_host_end_turn()

func on_action_bake(attack: AttackInstance):
	for effect: Effect in effects: effect.on_action_bake(attack)

func on_start_host_is_target(attack: AttackInstance):
	for effect: Effect in effects: effect.on_start_host_is_target(attack)
	
func on_is_target_bake(attack: AttackInstance):
	for effect: Effect in effects: effect.on_host_is_target_bake(attack)
	
func on_attack_baked(attack: AttackInstance):
	for effect: Effect in effects: effect.on_host_attack_baked(attack)
	
func on_got_hit(attack: AttackInstance):
	for effect: Effect in effects: # Current effects
		effect.on_host_got_hit(attack)
	
	for effect: Effect in attack.effects: # Effects delta
		append_effect(effect, effect.stackable)
	
	deal_damage(attack, attack.damage, []) # Take damage
	
func on_dealt_hit(attack: AttackInstance):
	for effect: Effect in effects: effect.on_host_dealt_hit(attack)

func deal_damage(cause: Resource, amount: int, _tags: Array[StringName]):
	print("amount: ", amount)
	#if !_tags.has(&"inert"):
	for effect: Effect in effects: amount = effect.on_host_receiving_damage(cause, amount, _tags)
	
	if amount != 0:
		if amount < 0 and _tags.has(&"overheal"): health -= amount
		else: health = clampf(health - amount, 0, max_health)
		
		damage_received.emit(cause, amount, _tags)
	else:
		damage_attempted.emit(cause, _tags)

func on_start_action(instance: AttackInstance): pass
