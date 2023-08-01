extends Node2D

enum { LEFT, RIGHT }
enum { FAR, NEAR }

onready var parent = get_parent()
onready var attack_timer = parent.get_node("AttackTimer")

var attack_count = 0
var attacking = false
var current_hand = LEFT
var forearms = []
var hands = []


func _ready():
	forearms.append(get_node("LeftArm/Forearm"))
	forearms.append(get_node("RightArm/Forearm"))
	hands.append(get_node("LeftArm/Forearm/Hand"))
	hands.append(get_node("RightArm/Forearm/Hand"))

var acts = 0
onready var b_press = false
func _process(_delta):
#	if is_instance_valid(parent.player) and parent.player_in_range:
#		extend_hand(LEFT)
	
	if not b_press and Input.is_key_pressed(KEY_B):
		b_press = true
#	if b_press and Input.is_key_pressed(KEY_H):
#		acts = 0
#		b_press = false
#		hands[LEFT].change_status(hands[LEFT].Open)
#		rest_position(LEFT)
	
#	if attack_timer.is_stopped() and acts == -1:
#		attack_timer.wait_time = parent.attack_cooldown
#		attack_timer.start()
	
#	actions()


func actions():
	if hands[current_hand].tween_running():# or not b_press:
		if not Global.player_in_range:
			acts = 3
		else:
			return
	elif acts == -1:
		return
	
	match acts:
		0: prepare_attack(current_hand)
		1: extend_hand(current_hand)
		2:
			hands[current_hand].change_status(hands[current_hand].Close)
			rest_position(current_hand)
		_:
			acts = -1
			attack_count += 1
			b_press = false
			hands[current_hand].change_status(hands[current_hand].Open)
			
			if current_hand == LEFT:
				current_hand = RIGHT
			else:
				current_hand = LEFT
	
	if attack_count == parent.consecutive_attacks:
		attack_count = 0
		current_hand = LEFT
	else:
		acts += 1


func rest_position(arm):
	hands[arm].move(forearms[arm], forearms[arm].position, Vector2(0, 14),
		1.5 if arm == LEFT else 1.3)
	hands[arm].move(hands[arm], hands[arm].position,
		Vector2(-12 * hands[arm].get_claw_scale(), 0),
		1.5 if arm == LEFT else 1.3)
	hands[arm].start_tween()


func prepare_attack(arm):
	hands[arm].change_status(hands[arm].Prepare)
	hands[arm].move(forearms[arm], forearms[arm].position,
		Vector2(forearms[arm].position.x + (15 * scale.x),
				forearms[arm].position.y),
		0.5 if arm == LEFT else 0.3)
	hands[arm].start_tween()


func extend_hand(arm):
	hands[arm].move(forearms[arm], forearms[arm].position, Vector2(0, 0),# 0.1)
		1.5 if arm == LEFT else 1.3)
	
	var player_pos = Global.player.global_position
	var angle = player_pos.angle_to_point(hands[arm].global_position)
	var dist_coords = parent.arm_range * Global.tile_size
	dist_coords = dist_coords.rotated(angle)
	hands[arm].move(hands[arm], hands[arm].position, dist_coords,# 0.1)
		1.5 if arm == LEFT else 1.3)
	hands[arm].start_tween()


func spank(arm):
	hands[arm].move(hands[arm], hands[arm].position,
		Vector2(
			Global.player.global_position.x - hands[arm].global_position.x,
			Global.player.global_position.y - hands[arm].global_position.y),
		1.5 if arm == LEFT else 1.3)
	hands[arm].start_tween()


func _on_AttackTimer_timeout():
	acts = 0
