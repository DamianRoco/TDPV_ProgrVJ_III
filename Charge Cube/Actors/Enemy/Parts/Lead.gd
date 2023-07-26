extends RayCast2D

export(int) var amplitude = 180
export(int) var speed = 120
export(NodePath) var node_path

onready var rotary_node = get_node_or_null(node_path)

var stop_rotation : bool = false
var pointing : bool = false
export(Vector2) var target_pos = null
var initial_angle


func _ready():
	if is_instance_valid(rotary_node):
		initial_angle = rotary_node.rotation_degrees


func _process(delta):
	if (stop_rotation or not is_instance_valid(rotary_node) or
		(not is_instance_valid(Global.player) and target_pos == null)):
		return
	
	var angle = global_position.angle_to_point(get_pos()) * 180 / PI 
	if get_pos().x > global_position.x:
		scale.x = -1
		angle *= -1
		rotation_degrees = angle
		if angle > 0:
			angle -= 180
		else:
			angle += 180
	else:
		scale.x = 1
		rotation_degrees = angle
	
	if point_to_player() and angle_in_range(angle) or target_pos != null:
		pointing = true
		if rotary_node.rotation_degrees < angle - 1:
			rotary_node.rotation_degrees += speed * delta
		elif rotary_node.rotation_degrees > angle + 1:
			rotary_node.rotation_degrees -= speed * delta
		else:
			if target_pos != null:
				target_pos = null
			rotary_node.rotation_degrees = angle
	else:
		pointing = false
		if rotary_node.rotation_degrees < initial_angle - 1:
			rotary_node.rotation_degrees += speed * delta
		elif rotary_node.rotation_degrees > initial_angle + 1:
			rotary_node.rotation_degrees -= speed * delta
		else:
			rotary_node.rotation_degrees = initial_angle


func angle_in_range(angle) -> bool:
	return ((angle > -amplitude and angle < amplitude) or
			(angle < -(amplitude + 100) or angle > amplitude + 100))


func point_to_player() -> bool:
	return is_colliding() and get_collider().is_in_group("Player")


func get_pos() -> Vector2:
	if target_pos == null:
		return Global.player.global_position
	else:
		return target_pos
