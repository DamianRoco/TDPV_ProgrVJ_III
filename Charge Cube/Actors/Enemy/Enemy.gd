extends KinematicBody2D

const GRAVITY = 16
const FLOOR = Vector2.UP

export(int) var damage = 1
export(int) var health = 5
export(int) var max_speed = 64
export(int) var min_speed = 32

onready var animation_tree = $AnimationTree
onready var body_explosion = $BodyExplosion
onready var raycast = $RayCast
onready var sprites = $Body

var direction : int = -1
var speed : int
var caught : bool = false setget set_caught
var injured : bool = false
var movement = Vector2.ZERO


# Drag
var drag_divider : float
var drag_direction : float
var dragged : bool = false


func _process(_delta):
	if is_alive():
		match animation_tree.get_animation():
			"Idle", "Walk":
				if not caught and is_on_floor():
					raycast.ground_ctrl()
	
	if not caught:
		movement_ctrl()
	else:
		# warning-ignore:return_value_discarded
		drag_ctrl()


func is_alive():
	return health > 0


func set_caught(new_value):
	if new_value:
		animation_tree.change_animation("Caught")
	else:
		animation_tree.change_animation("Idle")
	caught = new_value


func flip():
	direction *= -1
	body_explosion.scale.x *= -1
	sprites.scale.x *= -1
	raycast.scale.x *= -1


func movement_ctrl():
	if is_alive():
		if animation_tree.get_animation() == "Walk":
			raycast.patrol_ctrl()
			movement.x = speed * direction
		elif animation_tree.get_animation() != "Hit":
			movement.x = 0
		
		movement.y += GRAVITY
		if movement.y > 128 * 3:
			movement.y = 128 * 3
		
		movement.x += drag_ctrl()
	else:
		movement.y = 0
	movement = move_and_slide(movement, FLOOR)


func damage_ctrl(damage_received : int, axis : Vector2 = Vector2.ZERO):
	if injured or not is_alive():
		return
	
	if not caught:
		rebound_ctrl(axis)
	if health - damage_received > 0:
		set_injured()
		health -= damage_received
		animation_tree.change_animation("Hit")
	else:
		health = 0
		animation_tree.change_animation("DeathHit")


func drag_ctrl() -> float:
	if dragged:
		drag_divider = 0.5 if drag_divider < 0.6 else drag_divider - 0.1
		return drag_direction * max_speed / drag_divider
	else:
		drag_divider = float(max_speed) / 13
		return 0.0


# Asegura que es dañado solo una vez por el dash del jugador.
func set_injured():
	injured = true
	yield(get_tree().create_timer(0.05), 'timeout')
	injured = false


func rebound_ctrl(axis : Vector2):
	movement.x += max_speed * axis.x
	movement.y += max_speed * -axis.y
	if axis.x == direction:
		flip()


func _on_DeathTimer_timeout():
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
