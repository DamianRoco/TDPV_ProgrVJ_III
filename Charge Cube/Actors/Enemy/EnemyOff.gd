tool
extends KinematicBody2D

enum Status { HEAD, LEGS, ARMS, BOTH }

const GRAVITY = 16
const FLOOR = Vector2.UP

export(int) var health = 3
export(int) var rebound_speed = 64
export(Status) var status setget set_status

onready var body = $Body
onready var body_explosion = $BodyExplosion
onready var body_particle = $BodyExplosion/Body
onready var feet_collision = $FeetCollision
onready var head_collision = $HeadCollision
onready var tween = $Tween
onready var hit_timer = $Tween/HitTimer
onready var arms = [
	$Body/LeftArm,
	$Body/RightArm,
	$BodyExplosion/LeftArm,
	$BodyExplosion/LeftHand,
	$BodyExplosion/RightArm,
	$BodyExplosion/RightHand
]
onready var feet = [
	$Body/Feet,
	$BodyExplosion/LeftFoot,
	$BodyExplosion/RightFoot
]

var caught : bool = false
var flashing : bool = false
var movement = Vector2.ZERO

# Drag
var drag_divider : float
var drag_direction : float
var dragged : bool = false

# Sounds
onready var ground_sound = $Sounds/GroundImpact
onready var hit_sound = $Sounds/Hit
onready var step1_sound = $Sounds/Step1
onready var step2_sound = $Sounds/Step2
var ground_contact = false


func _ready():
	if not Engine.editor_hint:
		$Body.visible = true
		$HeadCollision.disabled = false


func _process(_delta):
	if Engine.editor_hint:
		return
	if is_on_floor():
		if not ground_contact:
			ground_contact = true
			if feet[0].visible:
				step1_sound.playing = true
				step2_sound.playing = true
			else:
				ground_sound.playing = true
	else:
		ground_contact = false
	
	if not caught:
		movement_ctrl()
	else:
		# warning-ignore:return_value_discarded
		drag_ctrl()
	if not is_alive() and not body_particle.is_emitting():
		queue_free()


func is_alive():
	return health > 0


func flip():
	pass


func movement_ctrl():
	if is_alive():
		if is_on_floor() and not flashing:
			movement.x = 0
		
		movement.y += GRAVITY
		if movement.y > 128 * 3:
			movement.y = 128 * 3
		movement.x += drag_ctrl()
	else:
		movement.y = 0
	
	movement = move_and_slide(movement, FLOOR)


func damage_ctrl(damage_received : int, axis : Vector2 = Vector2.ZERO):
	if flashing or not is_alive():
		return
	
	if not caught:
		rebound_ctrl(axis)
	if health - damage_received > 0:
		flashing = true
		hit_sound.playing = true
		health -= damage_received
		tween_flash()
		hit_timer.start()
	else:
		health = 0
		death_hit()


func death_hit():
	body.visible = false
	feet_collision.set_deferred("disabled", true)
	head_collision.set_deferred("disabled", true)
	body_explosion.animation_start()


func drag_ctrl() -> float:
	if dragged:
		drag_divider = 0.5 if drag_divider < 0.6 else drag_divider - 0.1
		return drag_direction * rebound_speed / drag_divider
	else:
		drag_divider = float(rebound_speed) / 13
		return 0.0


func set_status(new_status):
	if Engine.editor_hint:
		var arms_status
		var feet_status
		match new_status:
			Status.HEAD:
				health = 3
				arms_status = false
				feet_status = false
			Status.ARMS:
				health = 4
				arms_status = true
				feet_status = false
			Status.LEGS:
				health = 4
				arms_status = false
				feet_status = true
			Status.BOTH:
				health = 5
				arms_status = true
				feet_status = true
		
		$Body/LeftArm.visible = arms_status
		$Body/RightArm.visible = arms_status
		$BodyExplosion/LeftArm.visible = arms_status
		$BodyExplosion/LeftHand.visible = arms_status
		$BodyExplosion/RightArm.visible = arms_status
		$BodyExplosion/RightHand.visible = arms_status
		
		$Body/Feet.visible = feet_status
		$BodyExplosion/LeftFoot.visible = feet_status
		$BodyExplosion/RightFoot.visible = feet_status
		$FeetCollision.disabled = not feet_status
	else:
		if not arms or not feet:
			return
		var arms_status = false
		var feet_status = false
		match new_status:
			Status.HEAD:
				health = 3
			Status.ARMS:
				if not arms[0].visible:
					health += 1
					arms_status = true
			Status.LEGS:
				if not feet[0].visible:
					health += 1
					feet_status = true
			Status.BOTH:
				if not arms[0].visible:
					health += 1
					arms_status = true
				if not feet[0].visible:
					health += 1
					feet_status = true
		
		if arms_status:
			for arm in arms:
				arm.visible = arms_status
		if feet_status:
			for foot in feet:
				foot.visible = feet_status
			feet_collision.set_deferred("disabled", not feet_status)
	status = new_status


func rebound_ctrl(axis : Vector2):
	movement.x += rebound_speed * axis.x
	movement.y += rebound_speed * -axis.y


func tween_flash():
	var initial = body.material.get_shader_param("flash_modifier")
	var final = 0.0
	if initial < 0.3:
		final = 0.5
	
	tween.interpolate_property(body.material, "shader_param/flash_modifier",
		initial, final, 0.05)
	tween.start()


func _on_HitTimer_timeout():
	flashing = false


func _on_Tween_tween_completed(_object, _key):
	if not hit_timer.is_stopped():
		tween_flash()
