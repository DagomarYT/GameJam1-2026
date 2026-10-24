extends Entity
class_name Player

@export var max_stamina: int = 20
var stamina: int = max_stamina :
	set(x):
		stamina = clampi(x, 0, max_stamina)

#TODO: held weapons (dual-wielding, two-handing, one hand empty, ...)
@export var attacks: Array = [] :# Should be (max) 2 (according to held weapons)
	set(x):
		attacks = x
		Game.call_deferred(&"update_buttons")
@export var spells: Array = [] :# For now should be max 3-4, something like that.
	set(x):
		spells = x
		Game.call_deferred(&"update_buttons")

func _init(_attacks: Array, _spells: Array) -> void:
	attacks = _attacks
	spells = _spells
	pass
	#Game.update_buttons()

func _ready() -> void:
	Game.player = self

func attempt_action(action: Action):
	if stamina >= action.stamina_cost:
		Game.perform_action(self, Game.enemy, action)
		stamina -= action.stamina_cost
