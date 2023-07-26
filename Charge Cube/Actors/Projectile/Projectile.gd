extends KinematicBody2D

onready var horizontal_rays = $RayCasts/Horizontals
onready var vertical_rays = $RayCasts/Verticals

var enemy_damage : int = 3
var player_damage : int = 10
var speed : float = 128
var carry_player : bool = false
var launched : bool = false setget set_launched
var movement : Vector2
var move_direction : Vector2
var target_pos : Vector2 = Vector2.ZERO
var exceptions = []
var rays = []
var projectile


func _ready():
	horizontal_rays.scale.x *= sign(move_direction.x)
	vertical_rays.scale.y *= sign(move_direction.y)
	
	for child in horizontal_rays.get_children():
		rays.append(child)
	for child in vertical_rays.get_children():
		rays.append(child)
	
	projectile.caught = true
	if projectile.is_in_group("Enemy"):
		$CollisionShape2D.set_deferred("disabled", true)
		$CollisionShape2D2.set_deferred("disabled", false)
	elif projectile.is_in_group("Player"):
		carry_player = true
	
	exceptions.append(self)
	for excep in exceptions:
		add_collision_exception_with(excep)
		for ray in rays:
			ray.add_exception(excep)


func initialize(direction, projectile_element, shooter = null, speed_multiplier = 1):
	move_direction = direction
	projectile = projectile_element
	global_position = projectile.global_position
	
	exceptions.append(projectile)
	if shooter != null:
		exceptions.append(shooter)
		player_damage = shooter.damage
	
	speed *= speed_multiplier


func _process(_delta):
	if is_instance_valid(projectile):
		if launched:
			movement = move_and_slide(move_direction.normalized() * speed)
			projectile.global_position = global_position
			if in_target_pos() or carry_player and projectile.dash.dashing:
				free_projectile()
		else:
			if carry_player and projectile.dash.dashing:
				projectile.dash.end_dash()
			projectile.global_position = global_position
	elif not is_queued_for_deletion():
		queue_free()


func in_target_pos() -> bool:
	if (move_direction.x > 0 and global_position.x < target_pos.x or
		move_direction.x < 0 and global_position.x > target_pos.x) or (
		move_direction.y > 0 and global_position.y < target_pos.y or
		move_direction.y < 0 and global_position.y > target_pos.y):
		return false
	return true


func set_launched(new_value):
	launched = new_value
	target_pos = move_direction + projectile.global_position


func element_in_array(object, array) -> bool:
	for element in array:
		if object == element:
			return true
	return false


func harm(body, impact_direction):
	if body.is_in_group("Enemy"):
		body.damage_ctrl(enemy_damage, impact_direction)
	elif body.is_in_group("Player"):
		body.damage_ctrl(player_damage, impact_direction)


func free_projectile():
	if is_instance_valid(projectile):
		projectile.caught = false
		projectile = null
	queue_free()


func _on_DetectionArea_body_entered(body):
	if element_in_array(body, exceptions) or not is_instance_valid(projectile):
		return
	
	var collide = false
	var impact_direction = Vector2.ZERO
	var collisions = []
	var i = 0
	for ray in rays:
		ray.force_raycast_update()
		var collider = ray.get_collider()
		if ray.is_colliding() and not element_in_array(collider, collisions):
			collide = true
			if collider.is_in_group("Wall"):
				var pos = ray.get_collision_point() - ray.get_collision_normal()
				var tile_pos = collider.world_to_map(pos)
				collider.destroy_tile(tile_pos, true)
			else:
				collisions.append(collider)
			
			if i < 3:
				impact_direction.x = horizontal_rays.scale.x
			else:
				impact_direction.y = vertical_rays.scale.y
		i += 1
	
	if collide:
		for collider in collisions:
			harm(collider, impact_direction)
		harm(projectile, impact_direction * -1)
		free_projectile()


func _on_DetectionArea_area_entered(area):
	if area.is_in_group("Electricity"):
		free_projectile()
