extends AnimatedSprite


func _ready():
	play("Start")


func visor_animation(axis, sprite):
	var degrees = sprite.rotation_degrees
	while degrees < 0:
		degrees += 360
	while degrees >= 360:
		degrees -= 360
	
	if degrees > 45:
		if degrees < 135:
			var x = axis.x
			axis.x = -axis.y
			axis.y = x
		elif degrees < 225:
			axis.x *= -1
			axis.y *= -1
		else:
			var x = axis.x
			axis.x = axis.y
			axis.y = -x
	
	if axis.x && axis.y:
		scale.x = axis.x
		scale.y = axis.y
		play("Diagonal")
	elif axis.x:
		scale.x = axis.x
		play("Right")
	elif axis.y:
		scale.y = axis.y
		play("Up")
	else:
		play("Idle")
