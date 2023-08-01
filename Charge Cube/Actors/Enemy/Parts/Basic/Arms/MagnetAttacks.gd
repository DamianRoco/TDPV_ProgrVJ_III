extends "res://Actors/Enemy/Parts/Basic/Arms/AttackModel.gd"

onready var hand = arms[LEFT].hand
onready var lead = arms[LEFT].get_node("Lead")
onready var projectile_scene = preload("res://Actors/Projectile/Projectile.tscn")
onready var direction = arms[LEFT].get_node("Direction")
onready var proximity = arms[LEFT].get_node("Direction/Proximity")

var body_trapped = false
var projectile = null
var body_in_hand = null
var trapped_nodes = []


func _ready():
	direction.add_exception(parent)
	proximity.add_exception(parent)
	hand.connect("body_entered", self, "_on_Hand_body_entered")
	hand.connect("body_exited", self, "_on_Hand_body_exited")
	var range_area = lead.get_node("Range")
	range_area.connect("body_entered", self, "_on_Range_body_entered")
	range_area.connect("body_exited", self, "_on_Range_body_exited")


func set_attack_num(attacking):
	if attacking:
		match attack_num:
			0:
				attack_num = 1
			1:
				attack_num = 2
			2:
				if not body_trapped and is_instance_valid(body_in_hand):
					trap_body(body_in_hand)
				else:
					if not is_instance_valid(projectile):
						drag_nodes(true)
					drag_entities()
			3:
				if not is_instance_valid(projectile):
					attack_num = 2
					lead.stop_rotation = false
	else:
		drag_nodes(false)
		attack_num = 0


func get_stop_movement(stop):
	if stop:
		return stop_movement and lead.pointing
	else:
		return stop_movement


func changes_in_death():
	drag_nodes(false)
	if is_instance_valid(projectile):
		projectile.free_projectile()


func process_update():
	if is_instance_valid(projectile) and lead.target_pos != null:
		projectile.global_position = hand.global_position


func is_player_in_range():
	if lead.pointing:
		turn()
		return true
	if body_trapped and is_instance_valid(projectile):
		shoot_projectile()
		lead.target_pos = null
		lead.stop_rotation = false
	return false


func set_impact_direction():
	pass


func drag_entities():
	if body_trapped:
		if lead.target_pos == null:
			shoot_projectile()
	else:
		for node in trapped_nodes:
			var drag_dir = hand.global_position - node.global_position
			node.drag_direction = drag_dir.normalized().x


func drag_nodes(drag):
	if trapped_nodes.size() and trapped_nodes[0].dragged != drag:
		for node in trapped_nodes:
			node.dragged = true if drag else false


func instance_projectile(target_pos, body):
	projectile = projectile_scene.instance()
	projectile.initialize(target_pos, body, parent, 3)
	Global.projectile_folder.call_deferred("add_child", projectile)


func shoot_projectile():
	if is_instance_valid(projectile):
		attack_num = 3
		lead.stop_rotation = true
		projectile.launched = true
	
	body_trapped = false


func turn():
	var in_left = (
		Global.player.global_position.x < parent.global_position.x + 5 * scale.x
	)
	if in_left and scale.x < 0 or not in_left and scale.x > 0:
		parent.flip()


func trap_body(body):
	body_trapped = true
	
	body.global_position = hand.global_position
	if body.is_in_group("Player"):
		direction.rotation_degrees = 0
		direction.force_raycast_update()
		proximity.force_raycast_update()
		while not direction.is_colliding() or proximity.is_colliding():
			if (direction.rotation_degrees < 89 or
				direction.rotation_degrees > 91):
				if direction.rotation_degrees < 80:
					direction.rotation_degrees += 10
				elif direction.rotation_degrees < 90:
					direction.rotation_degrees = 180
				else:
					direction.rotation_degrees -= 10
				direction.force_raycast_update()
				proximity.force_raycast_update()
			else:
				direction.rotation_degrees = -10
				break
		
		if direction.rotation_degrees > 90:
			body.global_position.x += 50 * scale.x
		
		
		var dir = direction.cast_to * scale.x
		dir = dir.rotated(direction.rotation_degrees * PI / 180 * scale.x)
		
		lead.target_pos = direction.global_position + dir
		instance_projectile(dir, body)
	else:
		var player_pos = Global.player.global_position
		var angle = direction.global_position.angle_to_point(player_pos)
		instance_projectile(direction.cast_to.rotated(angle), body)
		shoot_projectile()


func _on_Hand_body_entered(body):
	if (attack_num != 2 or body == parent or lead.stop_rotation or
		is_instance_valid(projectile) or
		body.is_in_group("Player") and body.dash.dashing):
		return
	
	body_in_hand = body
	drag_nodes(false)
	trap_body(body)

func _on_Hand_body_exited(body):
	if body == body_in_hand:
		body_in_hand = null


func _on_Range_body_entered(body):
	if not parent.is_alive() or body == parent:
		return
	if attack_num == 2:
		body.dragged = true
	trapped_nodes.append(body)


func _on_Range_body_exited(body):
	body.dragged = false
	trapped_nodes.erase(body)
