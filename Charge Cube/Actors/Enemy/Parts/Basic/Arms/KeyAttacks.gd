extends "res://Actors/Enemy/Parts/Basic/Arms/AttackModel.gd"

func set_attack_num(attacking):
	if attacking:
		attack_num += 1 if attack_num < 3 else -1
		main_arm = RIGHT if attack_num == 2 else LEFT
	else:
		attack_num = 0
		main_arm = LEFT
