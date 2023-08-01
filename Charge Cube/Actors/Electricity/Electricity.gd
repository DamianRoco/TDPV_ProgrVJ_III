extends Area2D

onready var electrocution_sound = $Electrocution


func _ready():
	$AnimationPlayer.play("Swing")


func _on_Electricity_body_entered(body):
	if body.is_in_group("Player"):
		body.damage_ctrl(body.health, Vector2.ZERO, true)
		electrocution_sound.playing = true
	elif body.is_in_group("Enemy"):
		body.damage_ctrl(body.health)
		electrocution_sound.playing = true
