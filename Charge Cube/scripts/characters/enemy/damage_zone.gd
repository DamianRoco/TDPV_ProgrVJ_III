extends Area2D

var damage
var damage_applied : bool


func _on_Hand_body_entered(body):
	if body.is_in_group("player") and not damage_applied:
		damage_applied = true
		body.damage_ctrl(damage)
