extends Area2D

export(Global.Level) var go_to = Global.Level.NEXT

onready var gui = get_parent().get_node("GUI")


func _on_NextLevel_body_entered(body):
	body.stopped = true
	gui.level_fade_out()
	Global.save_terrain = true
	Global.spawn_player = false
	Global.go_to = go_to
