tool
extends Node2D

enum Enemies { EMPTY = -1, ENEMY_OFF, KEY, HAMMER, RIVETER, MAGNET, RANDOM }

export(Enemies) var enemy_type = Enemies.EMPTY
export(float) var speed = 1
export(float) var start_distance = 0
export(bool) var hide_lines = true
export(bool) var update_claw_positions = false
export(Array, Vector2) var movement_points

onready var rand = RandomNumberGenerator.new()

var clawns_speed = 0
var claw_current_points = []
var entity_scene
var enemies

var enemy_paths = [
	"res://Actors/Enemy/Basic/EnemyOff.tscn",
	"res://Actors/Enemy/Basic/Key.tscn",
	"res://Actors/Enemy/Basic/Hammer.tscn",
	"res://Actors/Enemy/Basic/Riveter.tscn",
	"res://Actors/Enemy/Basic/Magnet.tscn"
]


func _ready():
	if not Engine.editor_hint:
		rand.randomize()
		enemies = get_tree().get_root().get_node("Level/Enemies")
		clawns_speed = speed
		match enemy_type:
			Enemies.EMPTY:
				pass
			Enemies.RANDOM:
				entity_scene = []
				for path in enemy_paths:
					entity_scene.append(load(path))
			_:
				entity_scene = load(enemy_paths[enemy_type])
		
		for i in movement_points.size():
			movement_points[i] *= Global.tile_size
			movement_points[i] += global_position
		movement_points.append(global_position)
		
		if $Claws.get_child_count() > 0:
			deal_claws()
		
		var i = 0
		for child in get_node("Claws").get_children():
			child.movement_points = movement_points
			child.current_point = claw_current_points[i]
			i += 1


func _process(_delta):
	if Engine.editor_hint:
		update()
		if update_claw_positions and $Claws.get_child_count() > 0:
			deal_claws()
	else:
		speed = clawns_speed * Engine.time_scale


func _draw():
	if Engine.editor_hint and not hide_lines:
		if movement_points.size() > 0:
			draw_lines()


func convert_point(point):
	if Engine.editor_hint:
		return point * 16 + global_position
	else:
		return point


func draw_lines():
	var previous_point : Vector2 = Vector2.ZERO
	var color = Color(1.0, 0.5, 0.5, 1.0)
	for point in movement_points:
		draw_line(previous_point, point * 16, color)
		color = Color(1.0, 1.0, 0.5, 1.0)
		previous_point = point * 16
	draw_line(previous_point, Vector2.ZERO, Color(0.5, 1.0, 0.5, 1.0))


func get_total_distance():
	var total_distance = 0
	var last_point = global_position
	for point in movement_points:
		var current_point = convert_point(point)
		total_distance += last_point.distance_to(current_point)
		last_point = current_point
	total_distance += last_point.distance_to(global_position)
	return total_distance


func distance_to_position(distance, total_distance):
	for i in 2:
		var last_point = global_position
		var distance_count = 0
		var point_distance = 0
		var point_count = 0
		for point in movement_points:
			var current_point = convert_point(point)
			distance_count += last_point.distance_to(current_point)
			if distance < distance_count:
				distance -= point_distance
				var aux = last_point.move_toward(current_point, distance)
				return Vector3(aux.x, aux.y, point_count)
			point_distance = distance_count
			last_point = current_point
			point_count += 1
		
		distance_count += last_point.distance_to(global_position)
		if distance < distance_count:
			distance -= point_distance
			var aux = last_point.move_toward(global_position, distance)
			return Vector3(aux.x, aux.y, 0)
		distance -= total_distance


func instance_entity(pos):
	match enemy_type:
		Enemies.EMPTY:
			pass
		Enemies.RANDOM:
			var index = rand.randi_range(1, entity_scene.size() - 1)
			var entity_instance = entity_scene[index].instance()
			enemies.call_deferred("add_child", entity_instance)
			entity_instance.global_position = pos
		_:
			var entity_instance = entity_scene.instance()
			enemies.call_deferred("add_child", entity_instance)
			entity_instance.global_position = pos


func deal_claws():
	var total_distance = get_total_distance()
	var claw_spacing = total_distance / $Claws.get_child_count()
	var distance = start_distance * 16
	
	if distance < 0 or distance >= total_distance:
		print("ERROR: " + name + " excedió la distancia del camino.")
		return
	
	for child in $Claws.get_children():
		var coordinates = distance_to_position(distance, total_distance)
		child.global_position = Vector2(coordinates.x, coordinates.y)
		claw_current_points.append(int(coordinates.z))
		distance += claw_spacing
