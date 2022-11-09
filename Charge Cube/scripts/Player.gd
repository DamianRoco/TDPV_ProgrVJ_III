extends KinematicBody2D

const SPEED = 128
const FLOOR = Vector2.UP
const GRAVITY = 16
const JUMP_HEIGHT = 384
onready var movement = Vector2.ZERO

export(float, 0.01, 10) var JUMP_DIVIDER = 3
var can_dash : bool
var dash : bool
var jumping : bool
var coyoteTime : bool
var dash_movement : Vector2


func _ready():
	can_dash = true
	$Visor.play("Start")


func _process(_delta):
	dash_ctrl()
	jump_ctrl()
	movement_ctrl()
	visor_animation()


func get_axis() -> Vector2:
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed(("ui_right"))) - int(Input.is_action_pressed(("ui_left")))
	axis.y = int(Input.is_action_pressed(("ui_up"))) - int(Input.is_action_pressed(("ui_down")))
	return axis


func dash_ctrl():
	if can_dash and (get_axis().x or get_axis().y) and Input.is_action_just_pressed("dash"):
		dash_movement = get_axis()
		dash_movement.y *= -1
		dash = true
		can_dash = false
		$Dash.emitting = true
		$Timers/Dash.start()


func jump_ctrl():
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			movement.y -= JUMP_HEIGHT
			jumping = true
		else:
			jumping = false
			coyoteTime = false
	else:
		$Sparks.emitting = false
		
		if jumping:
			if movement.y < 0 and Input.is_action_just_released("jump"):
				movement.y /= JUMP_DIVIDER
		else:
			if not coyoteTime:
				$Timers/CoyoteTime.start()
				coyoteTime = true
			
			if not $Timers/CoyoteTime.is_stopped() and Input.is_action_just_pressed("jump"):
				movement.y -= JUMP_HEIGHT
				jumping = true


func movement_ctrl():
	match dash:
		true:
			movement = move_and_slide(dash_movement * SPEED * 3, FLOOR)
		false:
			movement.x = get_axis().x * SPEED
			movement.y += GRAVITY
			
			if get_axis().x and is_on_floor() and not is_on_wall():
				$Sparks.emitting = true
				
				if get_axis().x > 0:
					$Sparks.position.x = 6
				else:
					$Sparks.position.x = -6
			else:
				$Sparks.emitting = false
			
			movement = move_and_slide(movement, FLOOR)


func visor_animation():
	if get_axis().x && get_axis().y:
		$Visor.scale.x = int(get_axis().x)
		$Visor.scale.y = int(get_axis().y)
		$Visor.play("Diagonal")
	elif get_axis().x:
		$Visor.scale.x = int(get_axis().x)
		$Visor.play("Right")
	elif get_axis().y:
		$Visor.scale.y = int(get_axis().y)
		$Visor.play("Up")
	else:
		$Visor.play("Idle")


func _on_Dash_timeout():
	movement.y /= 2
	dash = false
	$Dash.emitting = false
	$Timers/CanDash.start()


func _on_CanDash_timeout():
	can_dash = true
