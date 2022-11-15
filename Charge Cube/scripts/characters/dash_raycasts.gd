extends Node2D

onready var orientation : Vector2 = Vector2.ZERO


func set_orientation(axis : Vector2):
	match axis == orientation:
		false:
			orientation = axis
			
			$Horizontals.scale.x = axis.x
			$Verticals.scale.y = -axis.y


func set_rays_visible(make_visible : bool):
	if orientation.x or not make_visible:
		$Horizontals.visible = make_visible
	if orientation.y or not make_visible:
		$Verticals.visible = make_visible


func destroy_tiles(tiles, collided_direction):
	if tiles.size() and collided_direction.x and collided_direction.y:
		# Al chocar con una esquina destruye el tile en diagonal al personaje.
		var point = Vector2.ZERO
		var normal = Vector2.ZERO
		
		point.x = tiles[0].get("collision_point").x
		point.y = tiles[tiles.size() - 1].get("collision_point").y
		
		normal.x = tiles[0].get("collision_normal").x
		normal.y = tiles[tiles.size() - 1].get("collision_normal").y
		
		var tile_pos = tiles[0].get("body").world_to_map(point - normal)
		tiles[0].get("body").set_cellv(tile_pos, -1)
	
	for tile in tiles:
		var point = tile.get("collision_point")
		var normal = tile.get("collision_normal")
		
		var tile_pos = tile.get("body").world_to_map(point - normal)
#		var tile_id = tile.get_cellv(tile_pos)
		tile.get("body").set_cellv(tile_pos, -1)


func detect_body():
	var enemy_collision : bool = false
	var collided_direction : Vector2 = Vector2.ZERO
	var tiles = []
	for i in 2:
		var child = get_child(i)
		if child.visible:
			for j in 2:
				child.get_child(j).force_raycast_update()
				var body = child.get_child(j).detect_collision()
				if body:
					if body is Dictionary:
						tiles.append(body)
					else:
						enemy_collision = true
						body.damage_ctrl(get_parent().damage)
					
					if i == 0:
						collided_direction.x = -orientation.x
					else:
						collided_direction.y = orientation.y
	
	destroy_tiles(tiles, collided_direction)
	
	if collided_direction.x or collided_direction.y:
		get_parent().dash_rebound(collided_direction)
		
		if enemy_collision:
			# Rehabilita el dash.
			get_parent().can_dash = true
			get_parent().get_node("Timers/CanDash").stop()


func _on_HorizontalDetector_body_entered(_body):
	detect_body()


func _on_VerticalDetector_body_entered(_body):
	detect_body()
