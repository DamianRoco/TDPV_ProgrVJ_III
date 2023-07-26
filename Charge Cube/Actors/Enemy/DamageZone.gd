extends Area2D

onready var arm = Global.get_parent_type(self, Position2D)
onready var parent = Global.get_parent_type(self, KinematicBody2D)
onready var sounds = []

var damage_applied : bool = true
var impact_direction : Vector2 = Vector2.ZERO


func _ready():
	var sound = get_node_or_null("HitSounds/Sound1")
	if is_instance_valid(sound):
		sounds.append(sound)
	sound = get_node_or_null("HitSounds/Sound2")
	if is_instance_valid(sound):
		sounds.append(sound)


func _on_Hand_body_entered(body):
	if not damage_applied:
		damage_applied = true
		body.damage_ctrl(parent.damage, impact_direction)
		
		if arm == null or sounds.size() != 2:
			return
		if arm.arm == "Front":
			sounds[0].playing = true
		else:
			sounds[1].playing = true
