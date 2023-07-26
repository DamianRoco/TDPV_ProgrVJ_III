extends Sprite

enum { RIGHT, LEFT }
enum Status { NULL, ADVANCE, RECEDE }

onready var arms = [$RightArm/Arm, $LeftArm/Arm]
onready var parent = get_parent()

var attack_num : int = 0
var main_arm : int = LEFT
var stop_movement : bool = true


func _process(_delta):
	if not parent.is_alive():
		changes_in_death()
		return
	
	if is_player_in_range():
		if (get_stop_movement(true) and
				parent.animation_tree.get_animation() != "Stop"):
			set_impact_direction()
			parent.animation_tree.change_animation("Stop")
		if not arms[main_arm].attacking:
			set_attack_num(true)
			if attack_num == 0:
				arms[RIGHT].end_attack()
				arms[LEFT].end_attack()
			else:
				arms[RIGHT].start_attack(attack_num, main_arm == RIGHT)
				arms[LEFT].start_attack(attack_num, main_arm == LEFT)
	elif arms[main_arm].status != Status.NULL:
		if not arms[main_arm].attacking:
			arms[RIGHT].end_attack()
			arms[LEFT].end_attack()
			set_attack_num(false)
	elif (get_stop_movement(false) and
			parent.animation_tree.get_animation() == "Stop"):
		parent.animation_tree.change_animation("Idle")
	process_update()


func get_stop_movement(_stop):
	return stop_movement

func is_player_in_range():
	return arms[main_arm].player_in_range

func changes_in_death():
	pass

func process_update():
	pass

func set_impact_direction():
	arms[RIGHT].set_impact_direction(Vector2(scale.x * -0.1 * parent.damage, 0))
	arms[LEFT].set_impact_direction(Vector2(scale.x * -0.1 * parent.damage, 0))

func set_attack_num(_attacking):
	pass
