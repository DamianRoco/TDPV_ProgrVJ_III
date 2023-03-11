extends Control


func _ready():
	$VBoxContainer/StartButton.grab_focus()


func _on_StartButton_pressed():
	var _error = get_tree().change_scene("res://Levels/Other.tscn")

func _on_OptionsButton_pressed():
	pass

func _on_QuitButton_pressed():
	get_tree().quit()
