extends Position2D

var animation_player
var parent setget set_parent

onready var grounded : bool = true


func set_parent(new_parent):
	parent = new_parent
	animation_player = parent.get_node("AnimationPlayer")


func attack_ctrl():
	if animation_player.current_animation != "attack" and $Attack.is_colliding():
		var collider = $Attack.get_collider()
		if collider.is_in_group("player") and not collider.dash.is_dashing():
			animation_player.attacking = true
			animation_player.play("attack")


func check_tiles(front = false):
	var raycast = $Back
	if front:
		raycast = $Front
	raycast.force_raycast_update()
	if raycast.is_colliding():
		if front:
			check_tiles()
		else:
			animation_player.change_animation("idle")
	else:
		animation_player.change_animation("walk")
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
					animation_player.change_animation("idle")


func patrol_ctrl():
	if $Patrol.is_colliding():
		if $Patrol.get_collider().is_in_group("player"):
			parent.speed = parent.max_speed
		else:
			parent.speed = parent.min_speed
	else:
		parent.speed = parent.min_speed
	
	match parent.speed:
		parent.max_speed:
			animation_player.set_speed_scale(2)
		parent.min_speed:
			animation_player.set_speed_scale(1)
