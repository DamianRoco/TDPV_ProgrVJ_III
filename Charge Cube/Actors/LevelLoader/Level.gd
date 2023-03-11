extends Node2D

export var show_colliders = false

onready var camera : Camera2D = get_tree().get_nodes_in_group("Camera")[0]
onready var player : KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]


func _ready():
	if show_colliders:
		get_tree().set_debug_collisions_hint(true)
	
	if Global.level_start:
		Global.spawn_point = player.global_position
		Global.level_start = false
	
	camera.global_position = Global.spawn_point
	player.global_position = Global.spawn_point


func _process(_delta):
	if Input.is_key_pressed(KEY_SPACE):
		var _error = get_tree().change_scene("res://Levels/Other.tscn")
