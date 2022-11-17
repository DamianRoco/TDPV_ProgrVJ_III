extends Node2D

export var show_colliders = false


func _ready():
	if show_colliders:
		get_tree().set_debug_collisions_hint(true)
	
	if Global.level_start:
		Global.spawn_point = get_parent().get_node("Player").global_position
		Global.level_start = false
	
	get_parent().get_node("Camera").global_position = Global.spawn_point
	get_parent().get_node("Player").global_position = Global.spawn_point
