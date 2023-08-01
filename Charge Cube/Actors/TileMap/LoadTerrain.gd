extends Node2D

onready var parent = get_parent()


func _ready():
	Global.terrain = parent
	Global.terrain_loader = self
	if Global.save_terrain:
		Global.save_terrain = false
		save_map()


func load_map():
	var save_file := File.new()
	if not save_file.file_exists("user://save_map.save"):
		return false
	# warning-ignore:return_value_discarded
	save_file.open("user://save_map.save", File.READ)
	
	parent.clear()
	var i = 0
	while save_file.get_position() != save_file.get_len():
		var tile_pos := Vector2.ZERO
		tile_pos.x = save_file.get_float()
		tile_pos.y = save_file.get_float()
		var tile_index = save_file.get_float()
		parent.set_cellv(tile_pos, tile_index)
		
		if i > 6000:
			save_file.close()
			print('Error: infinite loop in "while" conditional.')
			return true
		else:
			i += 1
	save_file.close()
	return true


func save_map():
	var save_file := File.new()
	# warning-ignore:return_value_discarded
	save_file.open("user://save_map.save", File.WRITE)
	
	for tile_pos in parent.get_used_cells():
		save_file.store_float(tile_pos.x)
		save_file.store_float(tile_pos.y)
		save_file.store_float(parent.get_cellv(tile_pos))
	save_file.close()
