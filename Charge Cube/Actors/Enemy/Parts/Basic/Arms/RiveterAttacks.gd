extends "res://Actors/Enemy/Parts/Basic/Arms/AttackModel.gd"

onready var leads = [arms[LEFT].get_node("Lead"), arms[RIGHT].get_node("Lead")]
onready var river_scene = preload("res://Actors/Enemy/Parts/Basic/Rivet.tscn")


func set_attack_num(attacking):
	if attacking:
		if leads[main_arm].pointing:
			attack_num += 1 if attack_num < 3 else -1
			main_arm = RIGHT if attack_num == 3 else LEFT
			if attack_num > 1:
				shoot_rivet()
		else:
			attack_num = 0
			main_arm = LEFT
			if parent.animation_tree.get_animation() == "Stop":
				parent.animation_tree.change_animation("Idle")
	else:
		attack_num = 0
		main_arm = LEFT


func get_stop_movement(stop):
	if stop:
		if leads[main_arm].pointing:
			turn()
		return stop_movement and leads[main_arm].pointing
	else:
		return stop_movement


func set_impact_direction():
	pass


func turn():
	var in_left = (
		Global.player.global_position.x < parent.global_position.x + 5 * scale.x
	)
	if in_left and scale.x < 0 or not in_left and scale.x > 0:
		parent.flip()


func shoot_rivet():
	var rivet = river_scene.instance()
	Global.projectile_folder.add_child(rivet)
	rivet.global_position = arms[main_arm].hand.global_position
	rivet.damage = parent.damage
	var dir = rivet.global_position - leads[main_arm].global_position
	rivet.move_direction = dir
