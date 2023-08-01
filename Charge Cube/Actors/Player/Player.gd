extends KinematicBody2D

export(int) var damage = 1
export(int) var health = 100
export(bool) var turn_on = true

onready var animation_tree = $AnimationTree
onready var light = $Body/Visor/Light2D
onready var raycasts = $RayCasts
onready var sprites = $Body

# Dash
const DASH_DURATION = 0.2
const REBOUND_FORCE = 200
onready var dash = $Dash
onready var rebound_timer = $Timers/Rebound
var aiming_timer : float = 0
var dash_movement : Vector2

# Drag
var drag_divider : float
var drag_direction : float
var dragged : bool = false

# Jump
const GRAVITY = 16.0
const JUMP_HEIGHT = 384
export(float, 0.01, 10) var jump_divider = 3
onready var coyote_time = $Timers/CoyoteTime
var active_coyote : bool
var jumping : bool

# Movement
const FLOOR = Vector2.UP
const SPEED = 128
onready var sparks = $Sparks
var caught : bool = false
var stopped : bool = false setget set_stopped
var movement : Vector2
var move_direction : Vector2

# Sounds
onready var ground_sound = $Sounds/GroundImpact
onready var jump_sound = $Sounds/Jump
onready var sparks_sound = $Sounds/Sparks
var ground_contact = false


func _ready():
	if Global.hidden_level == Global.HiddenLevel.GO:
		light.color.a = 1


func _physics_process(delta):
	if not is_on_floor() and not caught:
		var speed = 4 if dash.dashing else 2
		sprites.rotation_degrees += delta * movement.x * speed
	else:
		var rot = round(sprites.rotation_degrees / 90)
		sprites.rotation_degrees = round(rot * 90)


func _process(delta):
	if GameTime.slow_time:
		aiming_timer += delta * 10
	
	if is_on_floor():
		if not ground_contact:
			ground_contact = true
			ground_sound.playing = true
	else:
		ground_contact = false
	
	match animation_tree.get_animation() == "TurnOn":
		false:
			move_direction = get_move_direction()
			dash_ctrl()
			if not caught:
				jump_ctrl()
	
	movement_ctrl()


func is_alive():
	return health > 0


func set_stopped(new_value):
	stopped = new_value
	if new_value and dash.dashing:
		dash.end_dash()


# Apaga al personaje cuando toca un enchufe (Socket)
func turn_off():
	caught = true
	health = -1
	animation_tree.set_animation("Off")


func get_move_direction():
	if stopped:
		return Vector2.ZERO
	return Vector2(
		int(Input.is_action_pressed("ui_right")) -
		int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_up")) -
		int(Input.is_action_pressed("ui_down"))
	)


func dash_ctrl():
	if not dash.can_dash or not is_alive() or stopped:
		aiming_timer = 0
		if not is_alive():
			if dash.dashing:
				dash.end_dash()
			if GameTime.slow_time:
				GameTime.normalize_time()
		return
	
	if Input.is_action_pressed("dash"):
		if aiming_timer < 1:
			GameTime.encourage_time()
		else:
			GameTime.normalize_time()
	else:
		if GameTime.slow_time:
			GameTime.normalize_time()
		else:
			aiming_timer = 0
		
		raycasts.set_rays_visible(false)
	
	var is_moving = move_direction.x or move_direction.y
	
	if is_moving and aiming_timer != 0 and Input.is_action_just_released("dash"):
		dash.start_dash(sprites, DASH_DURATION)
		
		dash_movement = move_direction
		dash_movement.y *= -1
		
		if dash_movement.x:
			$HorizontalDetector.set_deferred("monitoring", true)
		if dash_movement.y:
			$VerticalDetector.set_deferred("monitoring", true)
		
		raycasts.set_orientation(move_direction)
		raycasts.set_rays_visible(true)


func damage_ctrl(damage_received: int, impact_direction: Vector2 = Vector2.ZERO,
	electrical_damage: bool = false):
	if not dash.dashing or electrical_damage:
		if is_alive():
			if not impact_direction.is_equal_approx(Vector2.ZERO):
				rebound(impact_direction)
			health -= damage_received
			if health <= 0:
				health = 0
				animation_tree.set_animation("DeathHit")
				Statistics.player_deaths += 1
			else:
				animation_tree.set_animation("Hit")


func drag_ctrl() -> float:
	if dragged:
		drag_divider = 0.5 if drag_divider < 0.6 else drag_divider - 0.1
		return drag_direction * SPEED / drag_divider
	else:
		drag_divider = float(SPEED) / 13
		return 0.0


func jump_ctrl():
	if is_on_floor():
		if (Input.is_action_just_pressed("jump") and is_alive() and
			rebound_timer.is_stopped() and not stopped):
			movement.y -= JUMP_HEIGHT
			jumping = true
			jump_sound.playing = true
		else:
			jumping = false
			active_coyote = false
	else:
		sparks_sound.playing = false
		sparks.emitting = false
		
		if jumping:
			if movement.y < 0 and Input.is_action_just_released("jump"):
				movement.y /= jump_divider
		else:
			if not active_coyote:
				coyote_time.start()
				active_coyote = true
			
			if (not stopped and not coyote_time.is_stopped() and
				Input.is_action_just_pressed("jump") and
				rebound_timer.is_stopped() and is_alive()):
				movement.y -= JUMP_HEIGHT
				jumping = true
				jump_sound.playing = true


func movement_ctrl():
	match dash.dashing:
		true:
			animation_tree.hide_attack_line()
			var speed = dash_movement * SPEED * 3
			speed.x += drag_ctrl()
			movement = move_and_slide(speed, FLOOR) / 2
		false:
			animation_tree.visor_direction(move_direction, sprites)
			
			if not caught:
				if rebound_timer.is_stopped():
					if is_alive():
						movement.x = move_direction.x * SPEED
					elif is_on_floor():
						movement.x = 0
					movement.y += 1.7 if GameTime.slow_time else GRAVITY
					if movement.y > SPEED * 3:
						movement.y = SPEED * 3
				
				movement.x += drag_ctrl()
				
				if (move_direction.x and is_on_floor() and is_alive() and
					not is_on_wall()):
					sparks_sound.playing = true
					sparks.emitting = true
					
					if move_direction.x > 0:
						sparks.position.x = 6
					else:
						sparks.position.x = -6
				else:
					sparks_sound.playing = false
					sparks.emitting = false
				
				movement = move_and_slide(movement, FLOOR)
			else:
				# warning-ignore:return_value_discarded
				drag_ctrl()
				sparks_sound.playing = false
				sparks.emitting = false
				movement = Vector2.ZERO


func rebound(axis, dash_impact = false):
	if dash_impact:
		dash.end_dash()
		rebound_timer.wait_time = 0.15
	else:
		rebound_timer.wait_time = 0.05
	rebound_timer.start()
	
	if axis.x:
		movement.x += REBOUND_FORCE * axis.x
	if axis.y:
		movement.y += REBOUND_FORCE * axis.y


func _on_ClawUnderboss_boss_prepared():
	animation_tree.set_animation("VisorLightOff")
