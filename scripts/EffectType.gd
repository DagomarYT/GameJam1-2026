extends Resource
class_name EffectType

@export var name: StringName = &"Effect name"
@export_multiline("tooltip") var tooltip: String = "Effect tooltip"
@export var color: Color = Color.WHITE

@export var stackable: bool = true
@export var tags: Array[StringName] = []
@export var data: Dictionary[StringName, Variant] = {}

@export var effect: GDScript
