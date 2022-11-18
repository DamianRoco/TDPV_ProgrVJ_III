extends KinematicBody2D

const CAST_LENGTH = 15
const FLOOR = Vector2.UP
const GRAVITY = 16
const JUMP_HEIGHT = 384
const REBOUND_FORCE = 200
const SPEED = 128

export var damage = 1
export var health : int = 100
export(float, 0.01, 10) var jump_divider = 3

var dash : bool
var jumping : bool
var coyoteTime : bool
var dash_movement : Vector2

onready var can_dash : bool = true
onready var caught : bool = false
onready var charging : bool = true
onready var immunity : bool = false
onready var movement : Vector2 = Vector2.ZERO


func _process(_delta):
	match charging:
		false:
			dash_ctrl()
			if not caught:
				jump_ctrl()
			movement_ctrl()
			for i in get_slide_count():
				var collider = get_slide_collision(i).collider
				if collider is TileMap and collider.is_in_group("electricity"):
					damage_ctrl(100, true)


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
		
		if dash_movement.x:
			$HorizontalDetector.set_deferred("monitoring", true)
		if dash_movement.y:
			$VerticalDetector.set_deferred("monitoring", true)
		
		$Dash.emitting = true
		$RayCasts.set_rays_visible(true)
		$Timers/Dash.start()
		$Timers/Rebound.stop()


func damage_ctrl(damage_received : int, electrical_damage : bool = false):
	if not immunity and not dash or electrical_damage:
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
	match dash:
		true:
			movement = move_and_slide(dash_movement * SPEED * 3, FLOOR)
		false:
			$RayCasts.set_orientation(get_axis())
			$Visor.visor_animation(get_axis())
			
			if not caught:
				if $Timers/Rebound.is_stopped():
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
			else:
				$Sparks.emitting = false


func dash_rebound(axis):
	$Timers/Dash.stop()
	$Timers/Dash.emit_signal("timeout")
	$Timers/Rebound.start()
	
	movement.x += REBOUND_FORCE * axis.x
	movement.y += REBOUND_FORCE * axis.y


func _on_Dash_timeout():
	movement.y /= 2
	dash = false
	$Dash.emitting = false
	$HorizontalDetector.set_deferred("monitoring", false)
	$VerticalDetector.set_deferred("monitoring", false)
	$RayCasts.set_rays_visible(false)
	$Timers/CanDash.start()


func _on_CanDash_timeout():
	can_dash = true


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"hit":
			immunity = false


func _on_Visor_animation_finished():
	charging = false
