extends KinematicBody2D

signal boss_prepared

const GRAVITY = 16
const FLOOR = Vector2.UP

export(bool) var is_inactive = true
export(int) var arm_range = 9
export(float) var attack_cooldown = 3
export(float) var attack_speed = 1.5
export(int) var consecutive_attacks = 1
export(int) var damage = 5
export(int) var health = 35
export(int) var max_speed = 16
export(int) var min_speed = 8

onready var animation_tree = get_node("AnimationTree")

var direction : int = -1
var speed : int
var player_in_range : bool
var movement = Vector2.ZERO

var hands
var raycast
var sprites
var player


func _ready():
	pass # Replace with function body.


func _process(_delta):
	if not is_instance_valid(player):
		return
	if is_alive() and not is_inactive:
		match animation_tree.get_animation():
			"Idle", "Walk":
				raycast.attack_ctrl()
#				if is_on_floor():
#					raycast.ground_ctrl()
		movement_ctrl()


func is_alive():
	return health > 0


func boss_prepared_signal():
	emit_signal("boss_prepared")


#func set_player_in_range():
#	var dist = arm_range * Global.tile_size
#	if global_position.distance_to(player.global_position) < dist:
#		player_in_range = true
#	else:
#		player_in_range = false


func movement_ctrl():
	if is_alive() and not is_inactive:
		if animation_tree.get_animation() == "Walk":
			raycast.patrol_ctrl()
			movement.x = speed * direction
		else:
			if animation_tree.get_animation() == "Attack":
				movement.x = 0
	
#	movement.y += GRAVITY
#	if movement.y > 128 * 3:
#		movement.y = 128 * 3
#	movement = move_and_slide(movement, FLOOR)


func _on_Head_visor_on():
	animation_tree.set_animation("TurnOn")


func _on_Range_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true


func _on_Range_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false


func _on_DarknessController_camera_moved(player_node):
	player = player_node
	animation_tree.start_animations()
