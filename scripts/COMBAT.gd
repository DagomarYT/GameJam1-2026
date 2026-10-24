extends Node

var player: Entity = null
var enemy: Entity = Entity.new()

var player_turn: bool = true

var past_actions: Array[AttackInstance] = []

func leave_combat(entity: Entity):
	pass # TODO

func perform_action(actor: Entity, target: Entity, action: Action):
	var instance: AttackInstance = AttackInstance.new(actor, target, action)
	past_actions.insert(0, instance)
	if past_actions.size() > 3: past_actions.pop_back()

func end_turn():
	if player_turn:
		player.on_end_turn()
		enemy.on_start_turn()
	else:
		player.on_start_turn()
		enemy.on_end_turn()
	
	player_turn = !player_turn
