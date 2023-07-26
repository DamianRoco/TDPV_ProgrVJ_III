extends Node2D

export(bool) var first_intro = true

onready var cancel_rect = $CancelIntro

var canceled = false
var timer = 0


func _process(delta):
	if Input.is_action_pressed("ui_cancel") and not canceled:
		canceled = true
	
	if canceled:
		if timer > 0.5:
			# warning-ignore:return_value_discarded
			get_tree().change_scene("res://Levels/1-1.tscn")
		else:
			timer += delta
			cancel_rect.color.a = 1 * timer / 0.5


func _on_AnimationPlayer_intro_completed():
	if canceled:
		return
	if first_intro:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Levels/IntroPart2.tscn")
	else:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Levels/1-1.tscn")
