extends Node

var player: Entity = null
var enemy: Entity = Entity.new()

var player_turn: bool = true

var past_actions: Array[AttackInstance] = []

func leave_combat(entity: Entity):
	pass # TODO

# Interaction is handled thru this script by creating an intermediary AttackInstance Resource
# This resource fetches info, handles the calcs and is stored for future referance in past_actions
# Slightly convoluted system, but is capable of handling status- and passive effects

# Main way to declare an action being performed, should work correctly rn
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
