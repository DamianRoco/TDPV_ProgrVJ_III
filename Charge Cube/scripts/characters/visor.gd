extends AnimatedSprite


func _ready():
	play("Start")


func visor_animation(axis):
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
