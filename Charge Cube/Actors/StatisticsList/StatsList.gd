extends Node2D

export(Array, NodePath) var button_paths = []
export(Array, NodePath) var button_player_paths = []

onready var arm_player = $BlocksBackground/ParallaxLayer/ArmAnchor/AnimationPlayer
onready var menu_player = $MenuPlayer

var button_num : int = -1
var buttons_moved : int = 0
var buttons = []
var button_players = []


func _ready():
	menu_player.play("MoveCamera")
	
	for path in button_paths:
		var node = get_node(path)
		buttons.append(node)
	buttons[0].grab_focus()
	
	for path in button_player_paths:
		button_players.append(get_node(path))


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel") and button_num == -1:
		if menu_player.is_playing():
			menu_player.play("GoToStats")
			arm_player.playback_speed = 2
		elif not arm_player.is_playing():
			button_num = 1
			button_players[0].play("RemoveButton")
			button_players[1].play("RemoveButton")
			menu_player.play("HideMenu")


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"MoveToCenter":
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			for button in buttons:
				button.can_focus = true
			buttons_moved += 1
			if buttons_moved == button_players.size():
				buttons_moved = 0
				for player in button_players:
					player.play("WaverClaws")


func _on_Button_button_pressed(button_type):
	button_num = button_type
	if button_num == 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var index = 0
	for player in button_players:
		if button_type == index:
			player.play("ReleaseButton")
		else:
			player.play("RemoveButton")
		index += 1
	menu_player.play("HideMenu")


func _on_MenuPlayer_animation_started(anim_name):
	match anim_name:
		"HideMenu":
			for button in buttons:
				button.can_focus = false


func _on_MenuPlayer_animation_finished(anim_name):
	match anim_name:
		"MoveCamera", "GoToStats":
			for button in buttons:
				button.can_focus = false
			button_players[0].play("MoveToCenter")
			button_players[0].advance(0.7)
			button_players[1].play("MoveToCenter")
			button_players[1].advance(0.7)
		"HideMenu":
			Statistics.reset_stats()
			match button_num:
				0:
					# warning-ignore:return_value_discarded
					get_tree().change_scene("res://Levels/1-1.tscn")
				1:
					# warning-ignore:return_value_discarded
					get_tree().change_scene("res://Actors/Menu/Menu.tscn")
