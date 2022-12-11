extends AnimationPlayer

var hand
var attacking : bool
var parent setget set_parent


func set_parent(new_parent):
	parent = new_parent
	hand = parent.get_node("Hand")
	play("idle")


func change_animation(animation : String):
	match animation:
		"idle":
			if current_animation == "walk":
				play("idle")
		"walk":
			if current_animation == "idle":
				play("walk")


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"attack":
			if attacking:
				parent.movement.x = 0
				hand.damage_applied = false
		"idle":
			parent.movement.x = 0


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"attack":
			if attacking:
				attacking = false
				hand.damage_applied = true
				var anim_speed = get_speed_scale() * -1
				play("attack", -1, anim_speed, true)
			else:
				play("idle")
		"dead_hit":
			parent.queue_free()
		"hit":
			play("idle")
