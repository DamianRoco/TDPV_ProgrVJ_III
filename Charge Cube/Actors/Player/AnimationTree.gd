extends AnimationTree

onready var animation_tree = self
onready var animation_node = animation_tree.get("parameters/playback")


func _ready():
	turn_on()


func turn_on():
	yield(get_tree().create_timer(0.5), "timeout")
	animation_node.travel("BlendTree")


func set_animation(name):
	animation_node.travel(name)


func get_animation():
	return animation_node.get_current_node()


func change_axes(axes, sprite):
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
	animation_tree.set('parameters/BlendTree/Look/blend_position', axes)
