extends Node

enum HiddenLevel { COME, NONE, GO }
enum Level { PREVIOUS, NEXT }

var tile_size : int = 16
var level : Vector2 = Vector2(1, 1)
var show_intro : bool = true
var spawn_player : bool = false
var hidden_level = HiddenLevel.NONE

var active_checkpoint_name
var go_to = Level.NEXT
var save_terrain = true

var terrain
var enemy_folder
var projectile_folder
var player
var terrain_loader


func _ready():
	OS.window_fullscreen = true


func reset():
	go_to = Level.NEXT
	hidden_level = HiddenLevel.NONE
	level = Vector2(1, 1)
	save_terrain = true
	spawn_player = false


func get_level_name(hidden_level_entrance, max_levels) -> String:
	Statistics.save_stats()
	match hidden_level_entrance:
		HiddenLevel.COME:
			hidden_level = HiddenLevel.COME
			return str(level.x) + "-" + str(level.y)
		HiddenLevel.GO:
			hidden_level = HiddenLevel.GO
			return str(level.x) + "-" + str(level.y) + "-1"
	
	if hidden_level == HiddenLevel.NONE:
		match go_to:
			Level.PREVIOUS:
				if level.y == 1:
					level.y = max_levels
					level.x -= 1
				else:
					level.y -= 1
			Level.NEXT:
				if level.y == max_levels:
					level.y = 1
					level.x += 1
				else:
					level.y += 1
	
	return str(level.x) + "-" + str(level.y)


func get_parent_type(child, parent_type):
	var parent = child.get_parent()
	while parent != null:
		if parent is parent_type:
			return parent
		else:
			parent = parent.get_parent()
	return null
