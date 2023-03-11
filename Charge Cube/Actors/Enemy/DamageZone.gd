extends Area2D

onready var parent = get_parent()
var damage_applied : bool = false


func _on_Hand_body_entered(body):
	if body.is_in_group("Player") and not damage_applied:
		damage_applied = true
		body.damage_ctrl(parent.damage)
