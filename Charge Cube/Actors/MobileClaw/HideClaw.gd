extends Area2D

func _on_HideClaw_area_entered(area):
	if area.is_in_group("MobileClaw"):
		area.hide_claw(false)

func _on_HideClaw_area_exited(area):
	if area.is_in_group("MobileClaw"):
		area.hide_claw(true)
