extends KinematicBody2D

const GRAVITY = 16
const FLOOR = Vector2.UP

export(int) var damage = 1
export(int) var health = 5
export(int) var max_speed = 64
export(int) var min_speed = 32

onready var animation_tree = $AnimationTree
onready var hand = $Hand
onready var raycast = $RayCast
onready var sprites = $Body

var direction : int = -1
var speed : int
var caught : bool = false
var injured : bool = false
var movement = Vector2.ZERO


func _process(_delta):
	match animation_tree.get_animation():
		"Idle", "Walk":
			if is_alive():
				raycast.attack_ctrl()
			if not caught and is_on_floor():
				raycast.ground_ctrl()
	
	if caught and is_alive():
		animation_tree.change_animation("Caught")
	else:
		movement_ctrl()
	
	for i in get_slide_count():
		var collider = get_slide_collision(i).collider
		if collider is TileMap and collider.is_in_group("Electricity"):
			damage_ctrl(100)


func dying():
#	yield(get_tree().create_timer(0.8), 'timeout')
	queue_free()

func is_alive():
	return health > 0


func flip():
	direction *= -1
	sprites.scale.x *= -1
	hand.scale.x *= -1
	raycast.scale.x *= -1


func movement_ctrl():
	if is_alive():
		if animation_tree.get_animation() == "Walk":
			raycast.patrol_ctrl()
			movement.x = speed * direction
		else:
			if animation_tree.get_animation() == "Attack":
				movement.x = 0
	
	movement.y += GRAVITY
	if movement.y > 128 * 3:
		movement.y = 128 * 3
	movement = move_and_slide(movement, FLOOR)


func damage_ctrl(damage_received : int, axis : Vector2 = Vector2.ZERO):
	if injured or not is_alive():
		return
	
	if health - damage_received > 0:
		set_injured()
		health -= damage_received
		animation_tree.change_animation("Hit")
		if not caught:
			rebound_ctrl(axis)
	else:
		health = 0
		animation_tree.change_animation("DeadHit")


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


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
