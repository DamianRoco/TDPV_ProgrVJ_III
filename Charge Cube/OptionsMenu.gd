extends Control

export var game_menu = true
export(Array, NodePath) var button_player_paths = []

onready var menu_player = $MenuPlayer

var button_num : int = -1
var buttons_moved : int = 0
var button_players = []


func _ready():
	rect_position = Vector2(0, 300)
	modulate = Color(1, 1, 1, 0)
	for path in button_player_paths:
		button_players.append(get_node(path))


func _input(_event):
	if game_menu:
		if Input.is_action_just_pressed("ui_cancel"):
			if get_tree().paused:
				menu_player.play("HideMenu")
			else:
				menu_player.play("ShowMenu")


func button_action():
	match button_num:
		0:
			menu_player.play("HideMenu")
		1:
			if game_menu:
				# warning-ignore:return_value_discarded
				get_tree().change_scene("res://Levels/Menu.tscn")
			else:
				menu_player.play("HideMenu")


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"MoveToCenter":
			if not game_menu:
				button_players[1].play("WaverClaws")
			else:
				buttons_moved += 1
				if buttons_moved == button_players.size():
					for player in button_players:
						player.play("WaverClaws")
#		"ReleaseButton":
#			button_action()


func _on_Button_button_pressed(button_type):
	button_num = button_type
	var index = 0
	for player in button_players:
		if not game_menu and index == 0:
			index += 1
			continue
		if button_type == index:
			player.play("ReleaseButton")
		else:
			player.play("RemoveButton")
		index += 1
	button_action()


func _on_MenuPlayer_animation_started(anim_name):
	match anim_name:
		"ShowMenu":
			get_tree().paused = true
			if game_menu:
				button_players[0].play("MoveToCenter")
				button_players[0].advance(0.7)
			button_players[1].play("MoveToCenter")
			button_players[1].advance(0.7)

func _on_MenuPlayer_animation_finished(anim_name):
	match anim_name:
		"HideMenu":
			get_tree().paused = false
