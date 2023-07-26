extends Camera2D

export(int) var look_movement = 100

onready var look_timer = $LookTimer

var current_direction : int = 0
var look_direction : int = 0
var target = null

#####################################
func _process(_delta):
	global_position = global_position + Vector2(
		float(Input.is_key_pressed(KEY_L)) -
		float(Input.is_key_pressed(KEY_J)),
		float(Input.is_key_pressed(KEY_K)) -
		float(Input.is_key_pressed(KEY_I))
	)
#####################################


func _physics_process(_delta):
	if is_instance_valid(target):
		global_position.x = target.global_position.x
		global_position.y = target.global_position.y
		
		if target.is_in_group("Player"):
			look()


func player_is_moving():
	return 0 != (
		int(Input.is_action_pressed("ui_right")) -
		int(Input.is_action_pressed("ui_left"))
	) or (
		target.movement.y > 1 or
		target.movement.y < -1
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
		global_position.y += look_movement * -look_direction
