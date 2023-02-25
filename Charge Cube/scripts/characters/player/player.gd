extends KinematicBody2D

const CAST_LENGTH = 15
const FLOOR = Vector2.UP
const GRAVITY = 16
const JUMP_HEIGHT = 384
const REBOUND_FORCE = 200
const SPEED = 128
const DASH_DURATION = 0.2

export(int) var damage = 1
export(int) var health = 100
export(float, 0.01, 10) var jump_divider = 3

var jumping : bool
var coyoteTime : bool
var dash_movement : Vector2
var move_direction : Vector2

onready var caught : bool = false
onready var charging : bool = true
onready var immunity : bool = false
onready var movement : Vector2 = Vector2.ZERO
onready var dash = $Dash
onready var sprites = $Sprites


func _physics_process(delta):
	if not is_on_floor() and not caught:
		sprites.rotation_degrees += delta * movement.x * (4 if dash.is_dashing() else 2)
	else:
		sprites.rotation_degrees = round(round(sprites.rotation_degrees / 90) * 90)


func _process(_delta):
	match charging:
		false:
			move_direction = get_move_direction()
			dash_ctrl()
			if not caught:
				jump_ctrl()
			movement_ctrl()
			for i in get_slide_count():
				var collider = get_slide_collision(i).collider
				if collider is TileMap and collider.is_in_group("electricity"):
					damage_ctrl(100, true)


func get_move_direction() -> Vector2:
	return Vector2(
		int(Input.is_action_pressed(("ui_right"))) - int(Input.is_action_pressed(("ui_left"))),
		int(Input.is_action_pressed(("ui_up"))) - int(Input.is_action_pressed(("ui_down")))
	)


func dash_ctrl():
	if not dash.is_dashing() and dash.can_dash and (move_direction.x or move_direction.y) and Input.is_action_just_pressed("dash"):
		dash.start_dash(sprites, DASH_DURATION)
		
		dash_movement = move_direction
		dash_movement.y *= -1
		
		if dash_movement.x:
			$HorizontalDetector.set_deferred("monitoring", true)
		if dash_movement.y:
			$VerticalDetector.set_deferred("monitoring", true)
		
		$RayCasts.set_orientation(move_direction)
		$RayCasts.set_rays_visible(true)
	elif not dash.is_dashing():
		$RayCasts.set_rays_visible(false)


func damage_ctrl(damage_received : int, electrical_damage : bool = false):
	if not immunity and not dash.is_dashing() or electrical_damage:
		if health > 0:
			health -= damage_received
			if health < 0:
				health = 0
			immunity = true
			$AnimationPlayer.play("hit")


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
				movement.y /= jump_divider
		else:
			if not coyoteTime:
				$Timers/CoyoteTime.start()
				coyoteTime = true
			
			if not $Timers/CoyoteTime.is_stopped() and Input.is_action_just_pressed("jump"):
				movement.y -= JUMP_HEIGHT
				jumping = true


func movement_ctrl():
	match dash.is_dashing():
		true:
			var speed = dash_movement * SPEED * 3
			movement = move_and_slide(speed, FLOOR) / 2
		false:
			$Sprites/Visor.visor_animation(move_direction, sprites)
			
			if not caught:
				if $Timers/Rebound.is_stopped():
					movement.x = move_direction.x * SPEED
					movement.y += GRAVITY
				
				if move_direction.x and is_on_floor() and not is_on_wall():
					$Sparks.emitting = true
					
					if move_direction.x > 0:
						$Sparks.position.x = 6
					else:
						$Sparks.position.x = -6
				else:
					$Sparks.emitting = false
				
				movement = move_and_slide(movement, FLOOR)
			else:
				$Sparks.emitting = false


func dash_rebound(axis):
	dash.end_dash()
	$Timers/Rebound.start()
	
	movement.x += REBOUND_FORCE * axis.x
	movement.y += REBOUND_FORCE * axis.y


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"hit":
			immunity = false


func _on_Visor_animation_finished():
	charging = false
