extends KinematicBody2D

const CAST_LENGTH = 15
const FLOOR = Vector2.UP
const GRAVITY = 16
const JUMP_HEIGHT = 384
const REBOUND_FORCE = 200
const SPEED = 128

export(float, 0.01, 10) var jump_divider = 3

var dash : bool
var jumping : bool
var coyoteTime : bool
var dash_movement : Vector2

onready var can_dash : bool = true
onready var movement : Vector2 = Vector2.ZERO


func _ready():
	$Visor.play("Start")
	
	###########
	get_tree().set_debug_collisions_hint(true)
	###########


func _process(_delta):
	visor_animation()
	dash_ctrl()
	rebound_ctrl()
	jump_ctrl()
	movement_ctrl()


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
		if dash_movement.x != 0:
			$RayCasts/Horizontal.enabled = true
		if dash_movement.y != 0:
			$RayCasts/Vertical.enabled = true


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


func rebound_ctrl():
	if not dash:
		return
	
	for i in 2:
		if $RayCasts.get_child(i).enabled and $RayCasts.get_child(i).is_colliding():
			var body = $RayCasts.get_child(i).get_collider()
			
			if body and body is TileMap and body.is_in_group("wall"):
				$Timers/Dash.stop()
				$Timers/Dash.emit_signal("timeout")
				$Timers/Rebound.start()
				
				var tile_pos = body.world_to_map($RayCasts.get_child(i).get_collision_point() - $RayCasts.get_child(i).get_collision_normal())
#				var tile_id = bodyH.get_cellv(tile_pos)
				body.set_cellv(tile_pos, -1)
				
				if i == 0:
					if $RayCasts.get_child(i).cast_to.x < 0:
						movement.x += REBOUND_FORCE
					else:
						movement.x -= REBOUND_FORCE
				elif $RayCasts.get_child(i).cast_to.y < 0:
					movement.y += REBOUND_FORCE
				else:
					movement.y -= REBOUND_FORCE


func visor_animation():
	if dash:
		return
	
	if get_axis().x && get_axis().y:
		$Visor.scale.x = int(get_axis().x)
		$Visor.scale.y = int(get_axis().y)
		$Visor.play("Diagonal")
		$RayCasts/Horizontal.cast_to.x = CAST_LENGTH * int(get_axis().x)
		$RayCasts/Vertical.cast_to.y = CAST_LENGTH * int(-get_axis().y)
	elif get_axis().x:
		$Visor.scale.x = int(get_axis().x)
		$Visor.play("Right")
		$RayCasts/Horizontal.cast_to.x = CAST_LENGTH * int(get_axis().x)
	elif get_axis().y:
		$Visor.scale.y = int(get_axis().y)
		$Visor.play("Up")
		$RayCasts/Vertical.cast_to.y = CAST_LENGTH * int(-get_axis().y)
	else:
		$Visor.play("Idle")


func _on_Dash_timeout():
	movement.y /= 2
	dash = false
	$Dash.emitting = false
	$Timers/CanDash.start()
	$RayCasts/Horizontal.enabled = false
	$RayCasts/Vertical.enabled = false


func _on_CanDash_timeout():
	can_dash = true


func _on_EntityDetector_body_entered(body):
	match dash:
		true:
			if body and body is KinematicBody2D and body.is_in_group("enemy"):
				body.damage_ctrl(1)
				can_dash = true
				
				if $RayCasts/Horizontal.enabled:
					if $RayCasts/Horizontal.cast_to.x < 0:
						movement.x += REBOUND_FORCE
					else:
						movement.x -= REBOUND_FORCE
				
				if $RayCasts/Vertical.enabled:
					if $RayCasts/Vertical.cast_to.y < 0:
						movement.y += REBOUND_FORCE
					else:
						movement.y -= REBOUND_FORCE
				
				$Timers/Dash.stop()
				$Timers/Dash.emit_signal("timeout")
				$Timers/Rebound.start()
