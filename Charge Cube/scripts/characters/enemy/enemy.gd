extends KinematicBody2D

const FLOOR = Vector2.UP
const GRAVITY = 16

export var damage = 1
export var health : int = 5
export var MAX_SPEED = 64
export var MIN_SPEED = 32

var speed : int

onready var direction : int = -1
onready var caught : bool = false
onready var movement = Vector2.ZERO


func _ready():
	$AnimationPlayer.play("idle")


func _process(_delta):
	match $AnimationPlayer.current_animation:
		"idle", "walk":
			$RayCast.attack_ctrl()
			if not caught and is_on_floor():
				$RayCast.ground_ctrl()
	
	if caught:
		$RayCast.change_animation("idle")
	else:
		movement_ctrl()
	
	for i in get_slide_count():
		var collider = get_slide_collision(i).collider
		if collider is TileMap and collider.is_in_group("electricity"):
			damage_ctrl(100)


func flip():
	direction *= -1
	$Sprites.scale.x *= -1
	$RayCast.scale.x *= -1


func movement_ctrl():
	if $AnimationPlayer.current_animation == "walk":
		$RayCast.patrol_ctrl()
		movement.x = speed * direction
	
	movement.y += GRAVITY
	movement = move_and_slide(movement, FLOOR)


func damage_ctrl(damage_received : int, axis : Vector2 = Vector2.ZERO):
	if health - damage_received > 0:
		health -= damage_received
		$AnimationPlayer.play("hit")
		if not caught:
			rebound_ctrl(axis)
	else:
		$AnimationPlayer.play("dead_hit")


func rebound_ctrl(axis : Vector2):
	movement.x += MAX_SPEED * axis.x
	movement.y += MAX_SPEED * -axis.y
	if axis.x == direction:
		flip()


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"attack":
			movement.x = 0
			$RayCast/Attack.get_collider().damage_ctrl(damage)
		"idle":
			movement.x = 0


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"attack":
			$AnimationPlayer.play("idle")
		"dead_hit":
			queue_free()
		"hit":
			$AnimationPlayer.play("idle")
