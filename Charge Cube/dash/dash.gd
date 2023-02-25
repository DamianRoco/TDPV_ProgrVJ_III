extends Node2D

const dash_delay = 1

onready var duration_timer = $DurationTimer
onready var ghost_timer = $GhostTimer

var ghost_scene = preload("res://dash/dash_ghost.tscn")
var can_dash = true
var sprite_rotation


func start_dash(sprite, duration):
	duration_timer.wait_time = duration
	duration_timer.start()
	
	sprite_rotation = sprite.rotation_degrees
	
	ghost_timer.start()
	instance_ghost()


func instance_ghost():
	var ghost : Sprite = ghost_scene.instance()
	get_parent().get_parent().add_child(ghost)
	
	ghost.global_position = global_position
	ghost.rotation_degrees = sprite_rotation


func is_dashing():
	return !duration_timer.is_stopped()


func end_dash():
	duration_timer.stop()
	ghost_timer.stop()
	
	can_dash = false
	yield(get_tree().create_timer(dash_delay), 'timeout')
	can_dash = true


func _on_DurationTimer_timeout():
	end_dash()


func _on_GhostTimer_timeout():
	instance_ghost()
