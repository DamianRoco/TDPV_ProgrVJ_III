extends Area2D

const SPEED = 128

onready var impact_sound = $RivetImpact

var damage : int
var move_direction : Vector2


func _process(delta):
	if visible:
		global_position += move_direction.normalized() * delta * SPEED
	elif not impact_sound.playing:
		queue_free()


func _on_Rivet_body_entered(body):
	if body.is_in_group("Player"):
		body.damage_ctrl(damage, move_direction.normalized() * 0.1)
	elif body.is_in_group("Enemy"):
		body.damage_ctrl(0, move_direction.normalized() * 0.1)
	visible = false
	impact_sound.playing = true
