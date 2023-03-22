extends Node2D

const DASH_DELAY = 1

onready var delay_timer = $DelayTimer
onready var duration_timer = $DurationTimer
onready var ghost_timer = $GhostTimer

var ghost_scene = preload("res://Actors/Dash/DashGhost.tscn")
var can_dash = true
var dashing = false
var sprite_rotation


func start_dash(sprite, duration):
	can_dash = false
	dashing = true
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


func end_dash(divider : float = 1):
	dashing = false
	duration_timer.stop()
	ghost_timer.stop()
	
	delay_timer.wait_time = DASH_DELAY / divider
	delay_timer.start()


func _on_DelayTimer_timeout():
	can_dash = true


func _on_DurationTimer_timeout():
	end_dash()


func _on_GhostTimer_timeout():
	instance_ghost()