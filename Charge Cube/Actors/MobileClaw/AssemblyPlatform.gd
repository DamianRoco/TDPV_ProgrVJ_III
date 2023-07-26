extends Area2D

export var object_path : String = ""

onready var sprite = $Sprite
onready var hit_timer = $HitTimer
onready var tween = $Tween
onready var object_scene = load(object_path)

onready var max_frames = sprite.vframes * sprite.hframes
onready var initial_pos = sprite.position

var player_in_claw = false
var mobile_claw = null


func _process(_delta):
	if is_instance_valid(mobile_claw):
		var object_trapped = is_instance_valid(mobile_claw.trapped_body)
		if sprite.frame == max_frames or not object_trapped:
			if object_trapped and not player_in_claw:
				replace_object()
			else:
				player_in_claw = false
			mobile_claw = null
			sprite.frame = 0
			tween.interpolate_property(sprite, "position", sprite.position,
				initial_pos, 0.5)
		else:
			tween.interpolate_property(sprite, "position", sprite.position,
				mobile_claw.global_position - global_position, 0.1)
		
		tween.start()


func move_forward():
	tween.interpolate_property(sprite, "frame", 0, max_frames, 0.8)
	tween.start()


func replace_object():
	var new_object = object_scene.instance()
	mobile_claw.trapped_body.get_parent().add_child(new_object)
	
	new_object.caught = true
	new_object.global_position = mobile_claw.trapped_body.global_position
	mobile_claw.trapped_body.queue_free()
	mobile_claw.trapped_body = new_object


func _on_AssemblyPlatform_area_entered(area):
	if area.is_in_group("MobileClaw") and is_instance_valid(area.trapped_body):
		mobile_claw = area
		if area.trapped_body.is_in_group("Player"):
			player_in_claw = true
			hit_timer.start()


func _on_Timer_timeout():
	if player_in_claw:
		mobile_claw.trapped_body.damage_ctrl(1)
		hit_timer.start()
