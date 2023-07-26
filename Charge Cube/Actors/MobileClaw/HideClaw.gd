extends Area2D

func _on_HideClaw_area_entered(area):
	area.visible = false

func _on_HideClaw_area_exited(area):
	area.visible = true
