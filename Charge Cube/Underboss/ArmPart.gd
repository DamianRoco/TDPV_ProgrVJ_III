tool
extends KinematicBody2D

export(NodePath) var node_path

onready var anchor_node = get_parent()
onready var next_node = get_node_or_null(node_path)


func _ready():
	var last_child = get_index() != get_parent().get_child_count() - 1
	if not is_instance_valid(next_node) and last_child:
		next_node = get_parent().get_child(get_index() + 1)


func _physics_process(_delta):
	if Engine.editor_hint:
		anchor_node = get_parent()
		var last_child = get_index() != get_parent().get_child_count() - 1
		if not is_instance_valid(next_node) and last_child:
			next_node = get_parent().get_child(get_index() + 1)
	
	if not is_instance_valid(next_node):
		return
	
	var orientation = Vector2.ZERO
	if (next_node.global_position.x < anchor_node.global_position.x - 1.5 or
		next_node.global_position.x > anchor_node.global_position.x + 1.5):
		orientation.x = 1
	else:
		global_position.x = anchor_node.global_position.x
	
	if (next_node.global_position.y < anchor_node.global_position.y - 1.5 or
		next_node.global_position.y > anchor_node.global_position.y + 1.5):
		orientation.y = 1
	else:
		global_position.y = anchor_node.global_position.y
	
	if orientation.x != 0 or orientation.y != 0:
		var anchor_pos = next_node.global_position
		var angle = anchor_node.global_position.angle_to_point(anchor_pos)
		var dist_coords = Vector2(3, 0).rotated(angle)
		
		if orientation.x != 0:
			global_position.x = next_node.global_position.x + dist_coords.x
		if orientation.y != 0:
			global_position.y = next_node.global_position.y + dist_coords.y


#func dist_to_coords(dist, ang):
#	var coords = Vector2.ZERO
#	coords.x = dist * cos(ang)
#	coords.y = dist * sin(ang)
#	return coords
