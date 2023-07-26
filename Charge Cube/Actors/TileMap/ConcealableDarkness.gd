extends Area2D

onready var animation = $AnimationPlayer


func _on_ConcealableDarkness_body_entered(body):
	if body.is_in_group("Player"):
		animation.play("FadeIn")

func _on_ConcealableDarkness_body_exited(body):
	if body.is_in_group("Player"):
		animation.play("FadeOut")
