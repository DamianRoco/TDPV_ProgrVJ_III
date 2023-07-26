extends AnimationTree

onready var animation_node = get("parameters/playback")
onready var parent = get_parent()

var emitted_signal = false


func _process(_delta):
	if parent.is_inactive:
		if get_animation() == "RepositionBody" and not emitted_signal:
			emitted_signal = true
			parent.boss_prepared_signal()
		return
	match get_animation():
		"Move":
			pass


func set_animation(name : String):
	animation_node.travel(name)


func get_animation():
	return animation_node.get_current_node()


#func is_animation(animation : String):
#	return animation_node.get_current_node() == animation


func start_animations():
	active = true
