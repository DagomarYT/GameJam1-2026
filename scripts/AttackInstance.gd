extends Resource
class_name AttackInstance

signal baked(attack_data: AttackInstance)

signal critical_hit(by: Entity, to: Entity, amount: int)

@export var action: Action

@export var host: Entity
@export var target: Entity

@export_category("Stats")
@export var damage: int = 0
@export var target_armor: int = 0

@export var crit_chance: float = 0.0
@export var crit_mult: float = 0.0
var crits: int = -1

@export var status_chance: float = 0.0
@export var effects: Array[Effect] = [] :
	set(x):
		for effect: Effect in effects:
			if !x.has(effect): remove_effect(effect, true)

@export var tags: Array[StringName] = []

func _init(_host: Entity, _target: Entity, _action: Action, auto_bake: bool = true):
	host = _host
	target = _target
	
	action = _action
	action.fetch_info(self) # get action stats
	
	# notify all involved parties of start of an AttackInstance: (attacker > weapon > action > target)
	host.on_start_action(self)
	host.weapon.on_start_action(self)
	action.on_start_used(self)
	target.on_start_host_is_target(self)
	
	if auto_bake: bake() # bake the attack

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
		#effect.host = self
		#effect.on_added(self)
	
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

func randf_chance(chance: float) -> int:
	var amount: int = 0
	var remainder: float = chance - floor(chance)
	
	randomize()
	
	if remainder >= randf_range(0.0, 1.0): amount += 1
	amount += int(chance)
	
	return amount

func bake(): # Final prep
	host.on_action_bake(self) # Passive effects
	action.on_used_bake(self)
	target.on_is_target_bake(self)
	
	var crit_amount: int = randf_chance(crit_chance) # Crits
	if crit_amount:
		damage = int(damage * (crit_mult ** crit_amount))
		critical_hit.emit(host, target, crit_amount)
		crits = crit_amount
	
	host.on_attack_baked(self)
	target.on_got_hit(self)
	host.on_dealt_hit(self)
	
	baked.emit(self)
