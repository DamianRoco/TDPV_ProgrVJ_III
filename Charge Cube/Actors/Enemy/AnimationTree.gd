extends AnimationTree

onready var animation_node = get("parameters/playback")
onready var death_timer = get_node("DeathTimer")


func get_animation():
	return animation_node.get_current_node()


func set_walk_speed(speed : float):
	set('parameters/Walk/TimeScale/scale', speed)


func change_animation(animation : String):
	match animation:
		"Idle":
			match get_animation():
				"Walk", "Caught", "Stop":
					animation_node.travel("Idle")
		"Walk":
			match get_animation():
				"Idle", "Caught":
					animation_node.travel("Walk")
		"Caught":
			match get_animation():
				"Idle", "Walk":
					animation_node.travel("Caught")
		_:
			animation_node.travel(animation)
			if animation == "DeathHit":
				death_timer.start()
				get_parent().body_explosion.animation_start()
