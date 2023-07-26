extends Area2D

const SPEED = 128

var damage : int
var move_direction : Vector2


func _process(delta):
	global_position += move_direction.normalized() * delta * SPEED


func _on_Rivet_body_entered(body):
	if body.is_in_group("Player"):
		body.damage_ctrl(damage, move_direction.normalized() * 0.1)
	elif body.is_in_group("Enemy"):
		body.damage_ctrl(0, move_direction.normalized() * 0.1)
	queue_free()
