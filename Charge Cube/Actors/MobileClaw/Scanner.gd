extends Area2D

onready var sprite = $Sprite
onready var timer = $Timer

var mobile_claw
var player


func _process(_delta):
	if is_instance_valid(player) and is_instance_valid(mobile_claw):
		sprite.frame = 2
		timer.start()
		player.caught = false
		player = null
		mobile_claw.free_body()


func _on_Area2D_area_entered(area):
	if area.is_in_group("MobileClaw"):
		mobile_claw = area

func _on_Area2D_area_exited(area):
	if area.is_in_group("MobileClaw"):
		mobile_claw = null

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		player = body
	else:
		sprite.frame = 1
		timer.start()

func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		player = null


func _on_Timer_timeout():
	sprite.frame = 0
