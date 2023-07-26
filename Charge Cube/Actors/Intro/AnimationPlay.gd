extends AnimationPlayer

signal intro_completed

export(bool) var send_signal = false

onready var animation_list = get_animation_list()

var current = 0


func _ready():
	play(animation_list[0])


func _on_AnimationPlayer_animation_finished(_anim_name):
	current += 1
	if current < animation_list.size():
		play(animation_list[current])
	elif send_signal:
		emit_signal("intro_completed")
