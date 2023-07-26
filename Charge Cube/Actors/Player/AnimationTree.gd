extends AnimationTree

onready var attack_line = get_parent().get_node("Body/AttackLine")
onready var animation_node = get("parameters/playback")
onready var slow_time = get_parent().get_node("SlowTime")


func _ready():
	if get_parent().turn_on:
		set_animation("TurnOn")


func set_animation(name):
	animation_node.travel(name)


func get_animation():
	return animation_node.get_current_node()


func hide_attack_line():
	attack_line.visible = false


func change_axes(axes, sprite):
	if slow_time.is_active and (axes.x or axes.y):
		var ang = Vector2(axes.x, axes.y * -1).angle()
		attack_line.rotation = ang - sprite.rotation
		attack_line.visible = true
	else:
		attack_line.visible = false
	
	var degrees = sprite.rotation_degrees
	while degrees < 0:
		degrees += 360
	while degrees >= 360:
		degrees -= 360
	
	if degrees > 45:
		if degrees < 135:
			var x = axes.x
			axes.x = -axes.y
			axes.y = x
		elif degrees < 225:
			axes.x *= -1
			axes.y *= -1
		elif degrees < 315:
			var x = axes.x
			axes.x = axes.y
			axes.y = -x
	
	return axes


func visor_direction(axes, sprite):
	axes = change_axes(axes, sprite)
	set('parameters/BlendTree/Look/blend_position', axes)
	var speed = 8 if slow_time.is_active else 2
	set('parameters/BlendTree/TimeScale/scale', speed)
