extends Position2D

onready var animation_tree = get_parent().get_node("AnimationTree")
onready var hand = get_parent().get_node("Hand")
onready var parent = get_parent()

var grounded : bool = true


func attack_ctrl():
	var animation = animation_tree.get_animation()
	if animation != "Attack" and animation != "Hit" and $Attack.is_colliding():
		var collider = $Attack.get_collider()
		if collider.is_in_group("Player") and not collider.dash.dashing:
			hand.damage_applied = false
			animation_tree.change_animation("Attack")


func check_tiles(front = false):
	var raycast = $Back
	if front:
		raycast = $Front
	
	raycast.force_raycast_update()
	if raycast.is_colliding():
		if front:
			check_tiles()
		else:
			animation_tree.change_animation("Idle")
	else:
		animation_tree.change_animation("Walk")
		if not front:
			parent.flip()


func ground_ctrl():
	if $GroundTimer.is_stopped():
		$GroundTimer.start()
		$Ground.force_raycast_update()
		if $Ground.is_colliding():
			grounded = true
			check_tiles(true)
			if $Ground.get_collider().is_in_group("electricity"):
				parent.flip()
		else:
			if grounded:
				grounded = false
			else:
				$GroundBehind.force_raycast_update()
				if $GroundBehind.is_colliding():
					check_tiles()
				else:
					animation_tree.change_animation("Idle")


func patrol_ctrl():
	if $Patrol.is_colliding():
		if $Patrol.get_collider().is_in_group("Player"):
			parent.speed = parent.max_speed
		else:
			parent.speed = parent.min_speed
	else:
		parent.speed = parent.min_speed
	
	match parent.speed:
		parent.max_speed:
			animation_tree.set_walk_speed(2)
		parent.min_speed:
			animation_tree.set_walk_speed(1)
