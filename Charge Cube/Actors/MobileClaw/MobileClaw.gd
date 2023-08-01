extends Area2D

export(float) var random_shake_strength : float = 3.0
export(float) var shake_decay_rate: float = 10.0
export(bool) var mute_sounds : bool = false

onready var animation_player = $AnimationPlayer
onready var broken_sound = $Sounds/Broken
onready var close_sound = $Sounds/Close
onready var open_sound = $Sounds/Open
onready var path = get_parent().get_parent()
onready var rand = RandomNumberGenerator.new()

var current_point : int = 0
var shake_strength : float = random_shake_strength
var broken : bool = false
var closed : bool = false
var in_kill_area : bool = false
var in_release_area : bool = false
var movement_points
var trapped_body


func _ready():
	rand.randomize()


func _process(delta):
	movement_ctrl()
	if is_instance_valid(trapped_body):
		if in_kill_area:
			mute_sounds = true
			if trapped_body.is_in_group("Player"):
				trapped_body.damage_ctrl(trapped_body.health)
			else:
				trapped_body.queue_free()
			free_body()
		elif in_release_area:
			trapped_body.caught = false
			free_body()
		else:
			if trapped_body.is_in_group("Player") and trapped_body.dash.dashing:
				break_claw()
			elif trapped_body.is_in_group("Enemy") and trapped_body.health <= 0:
				free_body()
			else:
				set_body_position(delta)
	elif closed and not broken:
		free_body()


func get_random_pos():
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)


func hide_claw(is_visible):
	visible = is_visible
	if is_visible:
		broken_sound.bus = "Sounds"
	else:
		broken_sound.bus = "Muted"


func set_body_position(delta):
	if trapped_body.dragged:
		if trapped_body.drag_divider > 0.6:
			shake_strength = lerp(
				random_shake_strength / trapped_body.drag_divider,
				0, shake_decay_rate * delta
			)
			trapped_body.global_position = global_position + get_random_pos()
		else:
			break_claw()
	else:
		shake_strength = random_shake_strength
		trapped_body.global_position = global_position


func break_claw():
	if not broken:
		if trapped_body:
			closed = false
			trapped_body.caught = false
			trapped_body = null
		broken = true
		animation_player.play("Broken")
		Statistics.broken_claws += 1


func repair_claw():
	if broken:
		broken = false
		animation_player.play("Open")


func free_body():
	trapped_body = null
	animation_player.play("Open")
	closed = false


func movement_ctrl():
	global_position = global_position.move_toward(
		movement_points[current_point],
		path.speed
	)
	if global_position.is_equal_approx(movement_points[current_point]):
		if current_point == movement_points.size() - 1:
			current_point = 0
		else:
			current_point += 1


func _on_AnimationPlayer_animation_started(anim_name):
	if not visible:
		return
	if mute_sounds:
		mute_sounds = false
		return
	match anim_name:
		"Close":
			close_sound.playing = true
		"Open":
			open_sound.playing = true


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
	match area.name:
		"KillArea":
			in_kill_area = true
		"ReleaseArea":
			in_release_area = true
		"RepairArea":
			mute_sounds = true
			repair_claw()
			if not closed:
				path.instance_entity(global_position)


func _on_MobileClaw_area_exited(area):
	match area.name:
		"KillArea":
			in_kill_area = false
		"ReleaseArea":
			in_release_area = false
