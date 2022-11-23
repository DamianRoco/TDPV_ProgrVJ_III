extends Position2D

onready var grounded : bool = true
onready var animation_player = get_parent().get_node("AnimationPlayer")
onready var parent = get_parent()


func _ready():
	$GroundTimer.start()


func attack_ctrl():
	if $Attack.is_colliding():
		var collider = $Attack.get_collider()
		if collider.is_in_group("player") and not collider.dash:
			animation_player.play("attack")


func change_animation(animation : String):
	match animation:
		"idle":
			if animation_player.current_animation == "walk":
				animation_player.play("idle")
		"walk":
			if animation_player.current_animation == "idle":
				animation_player.play("walk")


func check_tiles(front = false):
	var raycast = $Back
	if front:
		raycast = $Front
	raycast.force_raycast_update()
	if raycast.is_colliding():
		if front:
			check_tiles()
		else:
			change_animation("idle")
	else:
		change_animation("walk")
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
					change_animation("idle")
		


func patrol_ctrl():
	if $Patrol.is_colliding():
		if $Patrol.get_collider().is_in_group("player"):
			parent.speed = parent.MAX_SPEED
		else:
			parent.speed = parent.MIN_SPEED
	else:
		parent.speed = parent.MIN_SPEED
	
	match parent.speed:
		parent.MAX_SPEED:
			animation_player.set_speed_scale(2)
		parent.MIN_SPEED:
			animation_player.set_speed_scale(1)
