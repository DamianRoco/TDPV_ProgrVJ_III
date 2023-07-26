extends Position2D

enum Status { NULL, ADVANCE, RECEDE }

export(int) var body_frame setget set_body_frame
export(String, "Front", "Back") var arm = "Front"

onready var animation_player = $AnimationPlayer
onready var hand = $Sprites/Arm5/Hand
onready var parent = Global.get_parent_type(self, Sprite)

var attack_num : int = 0
var status : int = Status.NULL
var attacking : bool = false
var player_in_range : bool = false


func set_body_frame(new_frame):
	if not is_instance_valid(parent):
		return
	if arm == "Front" and parent.parent.is_alive():
		parent.frame = new_frame


func set_impact_direction(direction):
	hand.impact_direction = direction


func start_attack(attack, principal):
	status = Status.ADVANCE
	attack_num = attack
	attacking = true
	animation_player.play(str(attack_num) + "-" + arm + "Advance")
	if principal:
		hand.damage_applied = false


func end_attack():
	if status == Status.ADVANCE:
		status = Status.RECEDE
		attacking = true
		animation_player.play(str(attack_num) + "-" + arm + "Recede")
	else:
		status = Status.NULL
		attacking = false


func _on_AnimationPlayer_animation_finished(_anim_name):
	attacking = false
	if status == Status.ADVANCE:
		hand.damage_applied = true
	else:
		status = Status.NULL


func _on_Range_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true

func _on_Range_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
