@abstract
extends Resource
class_name Effect

#const type: EffectType = preload()

var host: Resource :
	set(x):
		if host: host_changed(host, x)
		host = x

var cause: Resource = null

var stacks: int = 1 :
	set(x):
		stacks = x
		if x < 1:
			host.remove_effect(self)
			call_deferred(&"free")

func _init(_host, _stacks: int = 1, _cause: Resource = null) -> void:
	host = _host
	stacks = _stacks
	cause = _cause

func randf_chance(chance: float) -> int:
	var amount: int = 0
	var remainder: float = chance - floor(chance)
	
	randomize()
	
	if remainder >= randf_range(0.0, 1.0): amount += 1
	amount += int(chance)
	
	return amount

func host_changed(old_host, new_host): pass

func on_added(host): pass
func on_stacks_changed(host, delta: int): pass
func on_removed(host): pass

func on_host_added_effect(effect: Effect) -> int:
	pass
	return effect.stacks
func on_host_removed_effect(effect: Effect): pass

func on_host_start_turn(): pass
func on_host_end_turn(): pass

func on_action_bake(attack: AttackInstance): pass

func on_start_host_is_target(attack: AttackInstance): pass
func on_host_is_target_bake(attack: AttackInstance): pass
func on_host_attack_baked(attack: AttackInstance): pass ## Called very last BEFORE actual damage dealing AFTER baking. (When action user.)
func on_host_got_hit(attack: AttackInstance): pass
func on_host_receiving_damage(cause: Resource, amount: int, tags: Array[StringName]) -> int:
	pass
	return amount
func on_host_dealt_hit(attack: AttackInstance): pass ## Called AFTER actual damage dealing. (When action user.)

func on_start_host_used(attack: AttackInstance): pass
func on_host_used_bake(attack: AttackInstance): pass
