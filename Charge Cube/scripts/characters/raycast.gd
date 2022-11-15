extends RayCast2D

var return_values = {}


func detect_collision():
	if is_colliding():
		var body = get_collider()
		if body.is_in_group("wall"):
			return_values["body"] = body
			return_values["collision_point"] = get_collision_point()
			return_values["collision_normal"] = get_collision_normal()
			return return_values
		return body
	return null
