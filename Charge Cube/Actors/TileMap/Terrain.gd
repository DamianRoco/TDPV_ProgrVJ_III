extends TileMap

const socket = preload("res://Actors/Socket/Socket.tscn")
export(int) var socket_cell = -1


func _process(_delta):
	for cellpos in get_used_cells():
		var cell = get_cellv(cellpos)
		if cell == socket_cell:
			var object = socket.instance()
			object.position = map_to_world(cellpos) * scale
			add_child(object)
			set_cellv(cellpos, -1)
