extends Control

onready var gui = $GUI

var button = -1


func _ready():
	$VBoxContainer/StartButton.grab_focus()


func set_button(num):
	button = num
	gui.level_fade_out()


func _on_GUI_screen_off():
	match button:
		0:
			var _error = get_tree().change_scene("res://Levels/Other.tscn")
		1:
			pass
		2:
			get_tree().quit()


func _on_StartButton_pressed():
	set_button(0)

func _on_OptionsButton_pressed():
	set_button(1)

func _on_QuitButton_pressed():
	set_button(2)
