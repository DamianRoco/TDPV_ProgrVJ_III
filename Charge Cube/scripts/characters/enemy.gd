extends KinematicBody2D

const FLOOR = Vector2.UP
const GRAVITY = 16

export var damage = 1
export var health : int = 5
export var MAX_SPEED = 64
export var MIN_SPEED = 32

var speed : int

onready var direction : int = 1
onready var can_move : bool = true
onready var caught : bool = false
onready var rebound : bool = false
onready var grounded : bool = true
onready var movement = Vector2.ZERO


func _ready():
	$AnimationPlayer.play("walk")
	$GroundTimer.start()


func _process(_delta):
	attack_ctrl()
	patrol_ctrl()
	if not caught:
		movement_ctrl()
	for i in get_slide_count():
				var collider = get_slide_collision(i).collider
				if collider is TileMap and collider.is_in_group("electricity"):
					damage_ctrl(100)


func attack_ctrl():
	if $RayCast/Attack.is_colliding() and can_move:
		if ($RayCast/Attack.get_collider().is_in_group("player") and
			not $RayCast/Attack.get_collider().dash):
			can_move = false
			$AnimationPlayer.play("attack")


func flip():
	direction *= -1
	$Sprite.scale.x *= -1
	$RayCast.scale.x *= -1


func patrol_ctrl():
	if $RayCast/Patrol.is_colliding():
		if $RayCast/Patrol.get_collider().is_in_group("player"):
			speed = MAX_SPEED
		else:
			speed = MIN_SPEED
	else:
		speed = MIN_SPEED


func movement_ctrl():
	if can_move:
		if is_on_wall():
			flip()
		elif $GroundTimer.is_stopped():
			$GroundTimer.start()
			
			$RayCast/Ground.force_raycast_update()
			if $RayCast/Ground.is_colliding():
				grounded = true
				if $RayCast/Ground.get_collider().is_in_group("electricity"):
					flip()
			else:
				if grounded:
					grounded = false
				else:
					flip()
		
		movement.x = speed * direction
		movement.y += GRAVITY
		
		movement = move_and_slide(movement, FLOOR)
	elif rebound:
		movement = move_and_slide(movement, FLOOR)


func damage_ctrl(damage_received : int, axis : Vector2 = Vector2.ZERO):
	if health - damage_received > 0:
		health -= damage_received
		$AnimationPlayer.play("hit")
		rebound_ctrl(axis)
	else:
		$AnimationPlayer.play("dead_hit")


func rebound_ctrl(axis : Vector2):
	rebound = true
	movement.x += MAX_SPEED * axis.x
	movement.y += MAX_SPEED * -axis.y
	if axis.x == direction:
		flip()


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"attack":
			$RayCast/Attack.get_collider().damage_ctrl(damage)
		"dead_hit":
			can_move = false
		"hit":
			can_move = false


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"attack":
			can_move = true
			$AnimationPlayer.play("walk")
		"dead_hit":
			queue_free()
		"hit":
			can_move = true
			rebound = false
			$AnimationPlayer.play("walk")
