extends AnimationTree

onready var animation_tree = self
onready var animation_node = animation_tree.get("parameters/playback")
onready var parent = get_parent()


func get_animation():
	return animation_node.get_current_node()


func set_walk_speed(speed):
	animation_tree.set('parameters/Walk/TimeScale/scale', speed)


func change_animation(animation : String):
	match animation:
		"Idle":
			if get_animation() == "Walk":
				animation_node.travel("Idle")
		"Walk":
			if get_animation() == "Idle":
				animation_node.travel("Walk")
		"Caught":
			if get_animation() == "Idle" or get_animation() == "Walk":
				animation_node.travel("Caught")
		_:
			animation_node.travel(animation)
			if animation == "DeadHit":
				parent.dying()
