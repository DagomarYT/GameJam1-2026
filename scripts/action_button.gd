extends TextureButton
class_name ActionButton

@export var action: Action = null :
	set(x):
		action = x
		update()

@export var type := action_types.spell
enum action_types{attack, spell}

func _ready() -> void:
	Game.player_buttons.append(self)
	if Game.player_buttons.find(self) < 2: type = action_types.attack
	pressed.connect(clicked)

func clicked():
	print(str(action))
	Game.player.attempt_action(action)

func update():
	if action and action.texture:
		texture_normal = action.texture
