extends KinematicBody2D

const FLOOR = Vector2.UP
const GRAVITY = 16
const SPEED = 48

export(int, 1, 10) var health : int = 5

onready var direction : int = 1
onready var can_move : bool = true
onready var grounded : bool = true
onready var movement = Vector2.ZERO


func _ready():
	$AnimationPlayer.play("walk")
	$RaycastTimer.start()


func _process(_delta):
	if can_move:
		movement_ctrl()


func movement_ctrl():
	if direction == 1:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false
	
	if is_on_wall():
		direction *= -1
		$RayCast.scale.x *= -1
	elif $RaycastTimer.is_stopped():
		$RaycastTimer.start()
		
		if $RayCast/Ground.is_colliding():
			grounded = true
		else:
			if grounded:
				grounded = false
			else:
				direction *= -1
				$RayCast.scale.x *= -1
	
	movement.x = SPEED * direction
	movement.y += GRAVITY
	
	movement = move_and_slide(movement, FLOOR)


func damage_ctrl(damage):
	if can_move:
		if health > 0:
			health -= damage
			$AnimationPlayer.play("hit")
		else:
			queue_free()


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"hit":
			can_move = false


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"hit":
			can_move = true
			$AnimationPlayer.play("walk")
