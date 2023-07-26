extends TileMap

enum { NORMAL = 3, ELECTRICITY = 6 }

const block_break_particles = preload("res://Actors/Particles/BlockBreakParticles.tscn")
const normal_block_explosion = preload("res://Actors/Particles/NormalBlockExplosion.tscn")
const electricity_block_explosion = preload("res://Actors/Particles/ElectricityBlockExplosion.tscn")

export(bool) var delete_tile = true
export(bool) var use_particles = false
export(Array, String) var object_paths = []
export(Array, int) var object_cells = []

var object_index = 0
var particle_count = [0, 0, 0]
var particles = []


func _ready():
	if use_particles:
		for i in 9:
			if i < 3:
				particles.append(block_break_particles.instance())
			elif i < 6:
				particles.append(normal_block_explosion.instance())
			else:
				particles.append(electricity_block_explosion.instance())
			add_child(particles[i])
	
	var objects_loaded = []
	for path in object_paths:
		objects_loaded.append(load(path))
	
	for cell_pos in get_used_cells():
		var cell = get_cellv(cell_pos)
		if replace_cell(cell):
			var object_instance = objects_loaded[object_index].instance()
			object_instance.position = map_to_world(cell_pos) * scale
			
			var cell_flip = Vector2(
				int(is_cell_x_flipped(cell_pos.x, cell_pos.y)),
				int(is_cell_y_flipped(cell_pos.x, cell_pos.y))
			)
			if cell_flip.x and cell_flip.y:
				object_instance.position += Vector2(16, 16)
				object_instance.rotation_degrees = 180
			elif cell_flip.x and not cell_flip.y:
				object_instance.position.x += 16
				object_instance.rotation_degrees = 90
			elif not cell_flip.x and cell_flip.y:
				object_instance.position.y += 16
				object_instance.rotation_degrees = 270
			
			add_child(object_instance)
			if delete_tile:
				set_cellv(cell_pos, -1)


func replace_cell(tile_cell):
	object_index = 0
	for target_cell in object_cells:
		if tile_cell == target_cell:
			return true
		object_index += 1
	return false


func destroy_tile(tile_pos, instant_break = false):
	var i
	var particle_instance
	var tile_id = get_cellv(tile_pos)
	
	if instant_break and tile_id != -1:
		if tile_id <= 2:
			tile_id = 2
		else:
			tile_id = 5
	
	match tile_id:
		-1: return
		2:
			i = 1
			particle_instance = particles[particle_count[i] + NORMAL]
			set_cellv(tile_pos, -1)
		5:
			i = 2
			particle_instance = particles[particle_count[i] + ELECTRICITY]
			set_cellv(tile_pos, -1)
		_:
			i = 0
			particle_instance = particles[particle_count[i]]
			set_cellv(tile_pos, tile_id + 1)
	
	if particle_count[i] == 2:
		particle_count[i] = 0
	else:
		particle_count[i] += 1
	
	var pos = map_to_world(tile_pos) + Vector2(8, 8)
	particle_instance.global_position = pos
	particle_instance.emitting = true
	
