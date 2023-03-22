extends TileMap

const electricity = preload("res://Actors/Electricity/Electricity.tscn")

export(int) var electricity_cell = -1


func _process(_delta):
	for cellpos in get_used_cells():
		var cell = get_cellv(cellpos)
		if cell == electricity_cell:
			var object = electricity.instance()
			object.position = map_to_world(cellpos) * scale
			add_child(object)
			set_cellv(cellpos, -1)
