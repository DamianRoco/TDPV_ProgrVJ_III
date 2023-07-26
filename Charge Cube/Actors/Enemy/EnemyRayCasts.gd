extends Position2D

onready var head_behind = $HeadBehind
onready var head_forward = $HeadForward
onready var ground_behind = $GroundBehind
onready var ground_forward = $GroundForward
onready var look = $Look
onready var patrol = $Patrol
onready var parent = get_parent()
onready var sounds = [
	parent.get_node("Sounds/Step1"),
	parent.get_node("Sounds/Step2"),
	parent.get_node("Sounds/Walk")
]


func change_sound_speed(speed):
	for sound in sounds:
		sound.pitch_scale = speed


func check_tiles(forward = false):
	var raycast = head_behind
	if forward:
		raycast = head_forward
	
	raycast.force_raycast_update()
	if raycast.is_colliding():
		if forward:
			check_tiles()
		else:
			parent.animation_tree.change_animation("Idle")
	else:
		parent.animation_tree.change_animation("Walk")
		if not forward:
			parent.flip()


func ground_ctrl():
	if ground_forward.is_colliding():
		check_tiles(true)
		if look.is_colliding() and look.get_collider().is_in_group("Electricity"):
			parent.flip()
	else:
		if ground_behind.is_colliding():
			check_tiles()
		else:
			parent.animation_tree.change_animation("Idle")


func patrol_ctrl():
	if patrol.is_colliding():
		if patrol.get_collider().is_in_group("Player"):
			parent.speed = parent.max_speed
		else:
			parent.speed = parent.min_speed
	else:
		parent.speed = parent.min_speed
	
	match parent.speed:
		parent.max_speed:
			var speed = (2 * float(parent.max_speed)) / 64
			parent.animation_tree.set_walk_speed(speed)
			change_sound_speed(speed)
		parent.min_speed:
			var speed = float(parent.min_speed) / 32
			parent.animation_tree.set_walk_speed(speed)
			change_sound_speed(speed)
