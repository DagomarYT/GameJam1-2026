extends Node

signal entity_moved(old_row: int, new_row: int, entity: Entity)

const ENTITY_LIMIT: int = 3
var rows: Array[Array] = [ # 0-2: gameplay, 3: escape row
	[],
	[],
	[],
	[] ]

var active_entities: Array[Entity] = []

var past_actions: Array[AttackInstance] = []

func get_relative_row(distance: int, current_row: int) -> int: return clampi(current_row - distance, 0, 3)

func get_total_row_width(row: int) -> int:
	var weight: int = 0
	for entity: Entity in rows[row]:
		weight += entity.width
	return weight

func can_move_to(row: int, width: int) -> bool:
	var row_limit: int = get_total_row_width(row)
	if row_limit + width <= ENTITY_LIMIT and rows.size() < ENTITY_LIMIT: return true
	return false

func get_distance_to_row(row: int, entity: Entity) -> int: return row - entity.row

func enter_combat(entity: Entity, row: int = 3) -> bool:
	if can_move_to(row, entity.width):
		# TODO
		
		return true
	return false

func move_row(distance: int, entity: Entity) -> bool:
	var old_row: int = entity.row
	var new_row: int = get_relative_row(distance, entity.row)
	if can_move_to(new_row, entity.row):
		rows[old_row].erase(entity)
		rows[new_row].append(entity)
		entity.row = new_row
		entity_moved.emit(old_row, new_row, entity)
		return true
	return false

func leave_combat(entity: Entity):
	pass # TODO

func perform_action(actor: Entity, target: Entity, action: Action):
	var instance: AttackInstance = AttackInstance.new(actor, target, action)
	past_actions.insert(0, instance)
	if past_actions.size() > 3: past_actions.pop_back()

var player: Entity = Entity.new()
var enemy: Entity = Entity.new()

var player_turn: bool = true

func end_turn():
	if player_turn:
		player.on_end_turn()
		enemy.on_start_turn()
	else:
		player.on_start_turn()
		enemy.on_end_turn()
	
	player_turn = !player_turn
