tool
extends Sprite

export(Vector2) var size = Vector2.ONE
export(Vector2) var inclination = Vector2.ZERO

var t = Transform2D()

func _process(_delta):
	t.x = Vector2(size.x, inclination.y)
	t.y = Vector2(inclination.x, size.y)
	transform = t

