tool
extends Position2D

enum { Close, Prepare, Open }

onready var bot = get_parent().get_parent().get_parent().get_parent()
onready var area = get_child(0)
onready var parent = get_parent()
onready var animation_node = area.get_node("AnimationTree").get("parameters/playback")
onready var sprite = area.get_node("Sprite")
onready var tween = area.get_node("Tween")


#onready var b_press = false
func _physics_process(_delta):
	if Engine.editor_hint and not is_instance_valid(parent):
		parent = get_parent()
	
	if parent.global_position.x >= global_position.x:
		if scale.x != 1:
			scale.x = 1
	elif scale.x != -1:
		scale.x = -1
	
#	if not b_press and Input.is_key_pressed(KEY_B):
#		b_press = true
#		move_to(Vector2(0, 0), 1)
	
	var rot = global_position.angle_to_point(parent.global_position) * 180 / PI
	if scale.x == 1:
		rot += 180
	rotation_degrees = rot

func get_claw_scale():
	return scale.x

func tween_running():
	return tween.is_active()

func start_tween():
	tween.start()

func stop_tween():
	if tween.is_active():
		tween.stop_all()


func change_status(status):
	if animation_node.is_playing():
		animation_node.stop()
	match status:
		Close:
			animation_node.travel("Close")
		Prepare:
			animation_node.travel("Prepare")
		Open:
			animation_node.travel("Open")
	
#	if close:
#		animation_node.travel("Close")
#	else:
#		if sprite.frame == 1:
#			animation_node.travel("Prepare")
#		else:
#			animation_node.travel("Open")


func move(object, initial_val, final_val, duration):
	tween.interpolate_property(object, "position",
		initial_val, final_val, duration)


func move_to(_point, time):
	var t = 0.5
	tween.interpolate_property(parent, "position", parent.position,
		Vector2(parent.position.x + (15 * scale.x), parent.position.y), t)
	tween.start()
#	animation_player.play("Open")
	yield(get_tree().create_timer(t), "timeout")
	
#	tween.interpolate_property(parent, "position", parent.position,
#		(bot.player.global_position - parent.global_position) / 2, time)
#	tween.interpolate_property(self, "position", position,
#		(bot.player.global_position - global_position) / 2, time)
	
	tween.interpolate_property(parent, "position", parent.position,
		Vector2(0,
#			(bot.player.global_position.x - parent.global_position.x) / 2,
			0),
		time)
	tween.interpolate_property(self, "position", position,
		Vector2(
			bot.player.global_position.x - global_position.x,
			bot.player.global_position.y - global_position.y), time)
	tween.start()
#	yield(get_tree().create_timer(time), "timeout")
	
#	animation_player.play("Close")
#	tween.interpolate_property(parent, "position", parent.position,
#		Vector2(0, 14), time)
#	tween.interpolate_property(self, "position", position,
#		Vector2(-12 * scale.x, 0), time)
#	tween.start()
#	yield(get_tree().create_timer(time), "timeout")
#	b_press = false
