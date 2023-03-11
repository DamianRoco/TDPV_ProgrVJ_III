extends Camera2D

export(int) var max_movement = 100
var current_child = 0
onready var target = get_parent().get_parent().get_node("Claws/Way").get_children()

onready var player : KinematicBody2D = get_tree().get_nodes_in_group("Player")[0]
onready var look_timer = $LookTimer

var current_direction : int = 0
var look_direction : int = 0


func _physics_process(_delta):
	global_position.x = player.global_position.x
	global_position.y = player.global_position.y
	if Input.is_action_just_pressed("ui_down"):
		current_child -= 1
	if Input.is_action_just_pressed("ui_up"):
		current_child += 1
	
	if current_child >= target.size():
		current_child = 0
	elif current_child < 0:
		current_child = target.size() - 1
	
	if Input.is_action_pressed("ui_accept") and is_instance_valid(target[current_child]):
		print(current_child)
		global_position.x = target[current_child].global_position.x
		global_position.y = target[current_child].global_position.y
	
	look()


func player_is_moving():
	return 0 != (
		int(Input.is_action_pressed("ui_right")) -
		int(Input.is_action_pressed("ui_left"))
	) or (
		player.movement.y > 1 or
		player.movement.y < -1
	)


func look():
	if player_is_moving():
		current_direction = 0
		look_timer.stop()
		return
	
	look_direction = (
		int(Input.is_action_pressed("ui_up")) -
		int(Input.is_action_pressed("ui_down"))
	)
	if look_direction != current_direction:
		current_direction = look_direction
		if current_direction != 0:
			look_timer.start()
	
	if look_timer.is_stopped() and current_direction != 0:
		global_position.y += 100 * -look_direction
