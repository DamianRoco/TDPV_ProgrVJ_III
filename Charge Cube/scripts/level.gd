extends Node2D

func _ready():
	if Global.level_start:
		Global.spawn_point = get_node("Player").global_position
		Global.level_start = false
	
	get_node("Camera").global_position = Global.spawn_point
	get_node("Player").global_position = Global.spawn_point
