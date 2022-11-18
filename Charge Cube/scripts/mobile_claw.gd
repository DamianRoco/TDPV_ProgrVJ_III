tool
extends Area2D

export var speed = 10
export(bool) var hide_lines = true
export(bool) var kill_trapped_body : bool = true
export(Array, Vector2) var movement_points

var trapped_body

onready var current_point : int = 0
onready var broken : bool = false
onready var closed : bool = false


func _ready():
	if not Engine.editor_hint:
		for i in movement_points.size():
			movement_points[i] *= Global.tile_size
			movement_points[i] += global_position
		movement_points.append(global_position)


func _process(_delta):
	if Engine.editor_hint:
		update()
	else:
		movement_ctrl()
		if is_instance_valid(trapped_body):
			if trapped_body.is_in_group("player") and trapped_body.dash:
				break_claw()
			else:
				trapped_body.global_position = global_position
		elif closed and not broken:
			free_body()


func _draw():
	if Engine.editor_hint and not hide_lines:
		if movement_points.size() > 0:
			var previous_point : Vector2 = Vector2.ZERO
			var color = Color(1.0, 0.5, 0.5, 1.0)
			for point in movement_points:
				draw_line(previous_point, point * 16, color)
				color = Color(1.0, 1.0, 0.5, 1.0)
				previous_point = point * 16
			draw_line(previous_point, Vector2.ZERO, Color(0.5, 1.0, 0.5, 1.0))


func break_claw():
	if not broken:
		if trapped_body:
			trapped_body.caught = false
			trapped_body = null
		broken = true
		$AnimationPlayer.play("broken")
		$CPUParticles.emitting = true


func free_body():
	trapped_body = null
	$AnimationPlayer.play("open")


func movement_ctrl():
	global_position = global_position.move_toward(movement_points[current_point], speed)
	if global_position.is_equal_approx(movement_points[current_point]):
		if current_point == movement_points.size() - 1:
				current_point = 0
				if kill_trapped_body and is_instance_valid(trapped_body):
					trapped_body.damage_ctrl(100)
					free_body()
		else:
			current_point += 1


func _on_MobileClaw_body_entered(body):
	if not broken and not trapped_body:
		if (body.is_in_group("player") or body.is_in_group("enemy")) and not body.caught:
			body.caught = true
			trapped_body = body
			$AnimationPlayer.play("close")


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"close":
			closed = true
		"open":
			closed = false
