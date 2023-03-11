extends Area2D

onready var animation_player = $AnimationPlayer
onready var speed = get_parent().speed

var current_point : int = 0
var broken : bool = false
var closed : bool = false
var movement_points
var trapped_body


func _process(_delta):
	movement_ctrl()
	if is_instance_valid(trapped_body):
		if trapped_body.is_in_group("Player") and trapped_body.dash.dashing:
			break_claw()
		elif trapped_body.is_in_group("Enemy") and trapped_body.health <= 0:
			free_body()
		else:
			trapped_body.global_position = global_position
	elif closed and not broken:
		free_body()


func break_claw():
	if not broken:
		if trapped_body:
			trapped_body.caught = false
			trapped_body = null
		broken = true
		animation_player.play("Broken")


func free_body():
	trapped_body.caught = false
	trapped_body = null
	animation_player.play("Open")
	closed = false


func movement_ctrl():
	global_position = global_position.move_toward(
		movement_points[current_point],
		speed
	)
	if global_position.is_equal_approx(movement_points[current_point]):
		if current_point == movement_points.size() - 1:
			current_point = 0
		else:
			current_point += 1


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Close":
			closed = true
		"Open":
			closed = false


func _on_MobileClaw_body_entered(body):
	if not broken and not trapped_body:
		if (body.is_in_group("Player") or
			body.is_in_group("Enemy")) and not body.caught:
			body.caught = true
			trapped_body = body
			animation_player.play("Close")


func _on_MobileClaw_area_entered(area):
	if not is_instance_valid(trapped_body):
		return
	if area.is_in_group("KillArea"):
		trapped_body.damage_ctrl(trapped_body.health)
		free_body()
	elif area.is_in_group("ReleaseArea"):
		free_body()
