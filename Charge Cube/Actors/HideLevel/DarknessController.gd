extends CanvasModulate

signal camera_moved(player_node)

onready var boss = get_tree().get_root().get_node("Level/Enemies").get_child(0)
onready var camera = get_tree().get_root().get_node("Level/Others/Camera")
onready var area = $Area2D
onready var tween = $Tween

var action_count = 0
var player


func move_camera(to_boss):
	if to_boss:
		tween.interpolate_property(camera, "position", camera.global_position,
			boss.global_position, 1)
	else:
		tween.interpolate_property(camera, "position", camera.global_position,
			player.global_position, 1)
	tween.start()


#tween.interpolate_property(object, "position",
#		initial_val, final_val, duration)

func _on_Area2D_body_entered(body):
	Engine.time_scale = 1
	AudioServer.global_rate_scale = 1
	camera.target = null
	player = body
	player.stopped = true
	boss.connect("boss_prepared", player, "_on_ClawUnderboss_boss_prepared")
	move_camera(true)
	area.queue_free()


func _on_ClawUnderboss_boss_prepared():
	tween.interpolate_property(self, "color", color, Color.white, 1)
	move_camera(false)


func _on_Tween_tween_all_completed():
	match action_count:
		0:
			emit_signal("camera_moved", player)
		1:
			camera.target = player
			player.stopped = false
			boss.is_inactive = false
			tween.interpolate_property(boss, "position", null,
				Vector2(boss.position.x + 200, boss.position.y), 2)
			tween.start()
	action_count += 1
