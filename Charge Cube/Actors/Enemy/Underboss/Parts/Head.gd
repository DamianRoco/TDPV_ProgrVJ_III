extends KinematicBody2D

onready var animation_player = get_node("AnimationPlayer")
onready var sprite = get_node("Sprite")
onready var parent = get_parent().get_parent()


func _process(_delta):
	if animation_player.is_playing() or not is_instance_valid(parent.player):
		return
	
	if parent.player.global_position.y < global_position.y - 20:
		sprite.frame_coords.y = 0
	elif parent.player.global_position.y > global_position.y + 20:
		sprite.frame_coords.y = 2
	else:
		sprite.frame_coords.y = 1


func damage_ctrl(damage_received : int, _orientation):
	if not parent.animation_tree.get_animation() == "Hit":
		if parent.is_alive():
			parent.health -= damage_received
			if parent.health <= 0:
				parent.health = 0
				parent.animation_tree.set_animation("DeathHit")
			else:
				animation_player.play("Hit")
