extends Node

# Global singleton script for keeping track of stuff. (it's bad, I know, srry)
# Haven't rlly made this kinda game before, so this is probably a mess, so srry abt that in advance.

var player: Player = null
var enemy: Enemy = null

var player_buttons: Array[ActionButton] = []

func _ready() -> void:
	player = Player.new(get_rand_resources(2, &"res://resources/actions/attacks/"), get_rand_resources(3, &"res://resources/actions/spell/"))
	gen_enemy()

func get_rand_resources(amount: int, dir: StringName) -> Array:
	var chosen: Array = []
	var all_list := load_all_resources(dir)
	for i: int in amount:
		var r: Resource = all_list.pick_random()
		all_list.erase(r)
		chosen.append(r)
	return chosen

func gen_enemy(): enemy = get_rand_resources(1, &"res://resources/enemies/")[0]

func update_buttons():
	var atk := player.attacks.duplicate()
	var spl := player.spells.duplicate()
	
	for button: ActionButton in player_buttons:
		if button.type == button.action_types.attack:
			button.action = atk.pop_front()
		else:
			button.action = spl.pop_front()

# loads all resources stored in a certain folder/directory
# for instance use: Game.load_all_resources(&"res://resources/actions/spell/") to get an Array of all spells
func load_all_resources(_dir: String) -> Array:
	var resources: Array = []
	var dir = DirAccess.open(_dir)

	dir.list_dir_begin()

	var file_name = dir.get_next()
	while file_name:
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var path = _dir + file_name
			var resource = load(path)

			if resource: resources.append(resource)

		file_name = dir.get_next()

	dir.list_dir_end()
	return resources

var player_turn: bool = true

var past_actions: Array[AttackInstance] = []

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
