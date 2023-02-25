extends KinematicBody2D

const GRAVITY = 16
const FLOOR = Vector2.UP

export(int) var damage = 1
export(int) var health = 5
export(int) var max_speed = 64
export(int) var min_speed = 32

var speed : int

onready var direction : int = -1
onready var caught : bool = false
onready var movement = Vector2.ZERO


func _ready():
	var this = $"."
	$AnimationPlayer.parent = this
	$Hand.damage = damage
	$RayCast.parent = this


func _process(_delta):
	match $AnimationPlayer.current_animation:
		"idle", "walk":
			$RayCast.attack_ctrl()
			if not caught and is_on_floor():
				$RayCast.ground_ctrl()
	
	if caught:
		$AnimationPlayer.change_animation("idle")
	else:
		movement_ctrl()
	
	for i in get_slide_count():
		var collider = get_slide_collision(i).collider
		if collider is TileMap and collider.is_in_group("electricity"):
			damage_ctrl(100)


func flip():
	direction *= -1
	$Sprites.scale.x *= -1
	$Hand.scale.x *= -1
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
	movement.x += max_speed * axis.x
	movement.y += max_speed * -axis.y
	if axis.x == direction:
		flip()
