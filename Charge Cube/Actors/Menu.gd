extends Control

export(bool) var play_sound setget set_play_sound
export(NodePath) var focus_button_path = ""
export(Array, NodePath) var button_paths = []
export(Array, NodePath) var button_player_paths = []

onready var options_menu = $OptionsMenu
onready var title_animation = $TitleAnimation

var button_num : int = -1
var buttons_moved : int = 0
var buttons = []
var button_players = []


func _ready():
	$ColorRect.visible = true
	
	title_animation.play("MoveTitle")
	for path in button_paths:
		var node = get_node(path)
		buttons.append(node)
		if path == focus_button_path:
			node.grab_focus()
			node.can_focus = true
	for path in button_player_paths:
		var node = get_node(path)
		node.play("MoveToCenter")
		button_players.append(node)


func set_play_sound(new_value):
	play_sound = new_value
	if new_value:
		SoundController.play_menu_music()
	else:
		SoundController.change_master_volume()


func button_action():
	match button_num:
		0:
			if Global.show_intro:
				Global.show_intro = false
				# warning-ignore:return_value_discarded
				get_tree().change_scene("res://Levels/IntroPart1.tscn")
			else:
				var level = str(Global.level.x) + "-" + str(Global.level.y)
				# warning-ignore:return_value_discarded
				get_tree().change_scene("res://Levels/" + level + ".tscn")
		1:
			options_menu.menu_player.play("ShowMenu")
		2:
			get_tree().quit()


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"MoveToCenter":
			buttons_moved += 1
			if buttons_moved == button_players.size():
				for player in button_players:
					player.play("WaverClaws")
		"ReleaseButton":
			if buttons_moved == button_players.size():
				buttons_moved += 1
				button_action()


func _on_Button_button_pressed(button_type):
	button_num = button_type
	if button_num == 1:
		button_action()
	else:
		title_animation.play("FadeOut")
		for button in buttons:
			button.can_focus = false
		var index = 0
		for player in button_players:
			if button_num == index:
				player.play("ReleaseButton")
			else:
				player.play("RemoveButton")
			index += 1


func _on_TitleAnimation_animation_started(anim_name):
	match anim_name:
		"MoveTitle":
			SoundController.play_menu_music()
