extends AnimationTree

onready var animation_tree = self
onready var animation_node = animation_tree.get("parameters/playback")
onready var death_timer = get_parent().get_node("DeathTimer")


func get_animation():
	return animation_node.get_current_node()


func set_walk_speed(speed):
	animation_tree.set('parameters/Walk/TimeScale/scale', speed)


func change_animation(animation : String):
	match animation:
		"Idle":
			match get_animation():
				"Walk", "Caught":
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
