extends Area2D

onready var accepted_sound = $Accepted
onready var refused_sound = $Refused
onready var sprite = $Sprite
onready var timer = $Timer

var player_passing : bool = false
var enemy_passing : bool = false
var mobile_claw


func _process(_delta):
	if is_instance_valid(mobile_claw) and player_passing:
		mobile_claw.in_release_area = true


func _on_Scanner_area_entered(area):
	if area.is_in_group("MobileClaw"):
		mobile_claw = area

func _on_Scanner_area_exited(area):
	if area.is_in_group("MobileClaw"):
		mobile_claw.in_release_area = false
		mobile_claw = null


func _on_Scanner_body_entered(body):
	if body.is_in_group("Player"):
		refused_sound.playing = true
		sprite.frame = 2
		player_passing = true
	else:
		enemy_passing = true
		if not player_passing:
			accepted_sound.playing = true
			sprite.frame = 1

func _on_Scanner_body_exited(body):
	if body.is_in_group("Player"):
		player_passing = false
		if enemy_passing:
			accepted_sound.playing = true
			sprite.frame = 1
		else:
			sprite.frame = 0
	else:
		enemy_passing = false
		sprite.frame = 0


func _on_Timer_timeout():
	sprite.frame = 0
