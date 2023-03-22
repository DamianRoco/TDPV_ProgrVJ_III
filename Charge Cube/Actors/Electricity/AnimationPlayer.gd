extends AnimationPlayer

func _ready():
	play("Swing")


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		body.damage_ctrl(body.health, true)
	elif body.is_in_group("Enemy"):
		body.damage_ctrl(body.health)
