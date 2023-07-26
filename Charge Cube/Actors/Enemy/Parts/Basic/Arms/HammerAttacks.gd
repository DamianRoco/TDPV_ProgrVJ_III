extends "res://Actors/Enemy/Parts/Basic/Arms/AttackModel.gd"

func set_attack_num(attacking):
	if attacking:
		if (Global.player.global_position.y < parent.global_position.y - 13 or
			attack_num == 4):
			if attack_num == 0:
				attack_num = 4
			elif attack_num < 4:
				attack_num = 0
			else:
				attack_num = 4 if attack_num == 5 else 5
		else:
			if attack_num == 5:
				attack_num = 0
			attack_num += 1 if attack_num < 3 else -1
		main_arm = RIGHT if attack_num == 2 else LEFT
	else:
		attack_num = 0
		main_arm = LEFT


func set_impact_direction():
	var mul = -0.6 if attack_num == 4 else -0.1
	arms[RIGHT].set_impact_direction(Vector2(scale.x * mul * parent.damage, 0))
	arms[LEFT].set_impact_direction(Vector2(scale.x * mul * parent.damage, 0))
