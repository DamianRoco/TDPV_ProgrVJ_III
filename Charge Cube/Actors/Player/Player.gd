extends KinematicBody2D

const CAST_LENGTH = 15
const DASH_DURATION = 0.2
const FLOOR = Vector2.UP
const GRAVITY = 16
const JUMP_HEIGHT = 384
const REBOUND_FORCE = 200
const SPEED = 128

export(int) var damage = 1
export(int) var health = 100
export(float, 0.01, 10) var jump_divider = 3

onready var animation_tree = $AnimationTree
onready var coyote_time = $Timers/CoyoteTime
onready var dash = $Dash
onready var raycasts = $RayCasts
onready var rebound_timer = $Timers/Rebound
onready var sparks = $Sparks
onready var sprites = $Body

var active_coyote : bool
var jumping : bool
var caught : bool = false
var dash_movement : Vector2
var movement : Vector2
var move_direction : Vector2


func _physics_process(delta):
	if not is_on_floor() and not caught:
		var speed = 4 if dash.dashing else 2
		sprites.rotation_degrees += delta * movement.x * speed
	else:
		var rot = round(sprites.rotation_degrees / 90)
		sprites.rotation_degrees = round(rot * 90)


func _process(_delta):
	match animation_tree.get_animation() == "TurningOn":
		false:
			move_direction = get_move_direction()
			dash_ctrl()
			if not caught:
				jump_ctrl()
			movement_ctrl()


func is_alive():
	return health > 0


func turn_off():
	caught = true
	health = -1
	animation_tree.set_animation("Off")


func get_move_direction():
	return Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_up")) - int(Input.is_action_pressed("ui_down"))
	)


func dash_ctrl():
	if not dash.can_dash or not is_alive():
		if not is_alive() and dash.dashing:
			dash.end_dash()
		return
	
	var is_moving = move_direction.x or move_direction.y
	if Input.is_action_just_pressed("dash") and not dash.dashing and is_moving:
		dash.start_dash(sprites, DASH_DURATION)
		
		dash_movement = move_direction
		dash_movement.y *= -1
		
		if dash_movement.x:
			$HorizontalDetector.set_deferred("monitoring", true)
		if dash_movement.y:
			$VerticalDetector.set_deferred("monitoring", true)
		
		raycasts.set_orientation(move_direction)
		raycasts.set_rays_visible(true)
	elif not dash.dashing:
		raycasts.set_rays_visible(false)


func damage_ctrl(damage_received : int, electrical_damage : bool = false):
	if (not animation_tree.get_animation() == "Hit" and not dash.dashing or
		electrical_damage):
		if is_alive():
			health -= damage_received
			if health <= 0:
				health = 0
				animation_tree.set_animation("DeathHit")
			else:
				animation_tree.set_animation("Hit")


func jump_ctrl():
	if is_on_floor():
		if (Input.is_action_just_pressed("jump") and is_alive() and
			rebound_timer.is_stopped()):
			movement.y -= JUMP_HEIGHT
			jumping = true
		else:
			jumping = false
			active_coyote = false
	else:
		sparks.emitting = false
		
		if jumping:
			if movement.y < 0 and Input.is_action_just_released("jump"):
				movement.y /= jump_divider
		else:
			if not active_coyote:
				coyote_time.start()
				active_coyote = true
			
			if (not coyote_time.is_stopped() and
				Input.is_action_just_pressed("jump") and
				rebound_timer.is_stopped() and is_alive()):
				movement.y -= JUMP_HEIGHT
				jumping = true


func movement_ctrl():
	match dash.dashing:
		true:
			var speed = dash_movement * SPEED * 3
			movement = move_and_slide(speed, FLOOR) / 2
		false:
			animation_tree.visor_direction(move_direction, sprites)
			
			if not caught:
				if rebound_timer.is_stopped():
					if is_alive():
						movement.x = move_direction.x * SPEED
					elif is_on_floor():
						movement.x = 0
					movement.y += GRAVITY
					if movement.y > SPEED * 3:
						movement.y = SPEED * 3
				
				if (move_direction.x and is_on_floor() and is_alive() and
					not is_on_wall()):
					sparks.emitting = true
					
					if move_direction.x > 0:
						sparks.position.x = 6
					else:
						sparks.position.x = -6
				else:
					sparks.emitting = false
				
				movement = move_and_slide(movement, FLOOR)
			else:
				sparks.emitting = false
				movement = Vector2.ZERO


func rebound(axis):
	dash.end_dash()
	rebound_timer.start()
	
	if axis.x:
		movement.x += REBOUND_FORCE * axis.x
	if axis.y:
		movement.y += REBOUND_FORCE * axis.y
