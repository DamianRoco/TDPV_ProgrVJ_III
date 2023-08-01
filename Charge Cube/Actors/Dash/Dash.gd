extends Node2D

const DASH_DELAY = 1

onready var dash_sound = $Dash
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
	dash_sound.playing = true
	duration_timer.start(duration)
	
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
	dash_sound.playing = false
	duration_timer.stop()
	ghost_timer.stop()
	
	delay_timer.start(DASH_DELAY / divider)


func _on_DelayTimer_timeout():
	can_dash = true


func _on_DurationTimer_timeout():
	end_dash()


func _on_GhostTimer_timeout():
	instance_ghost()
