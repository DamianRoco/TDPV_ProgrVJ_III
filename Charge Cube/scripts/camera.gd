extends Camera2D

onready var player : KinematicBody2D = get_tree().get_nodes_in_group("player")[0]


func _physics_process(_delta):
	global_position.x = player.global_position.x
	global_position.y = player.global_position.y
