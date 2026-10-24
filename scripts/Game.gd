extends Node

# Global singleton script for keeping track of stuff. (it's bad, I know, srry)
# Haven't rlly made this kinda game before, so this is probably a mess, so srry abt that in advance.

var player: Player = null
var enemy: Enemy = null

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
