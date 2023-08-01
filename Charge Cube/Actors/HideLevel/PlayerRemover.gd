extends Area2D

onready var arm = $ArmAnchor
onready var arm_player = $ArmAnchor/AnimationPlayer
onready var arm_moving_sound = $ArmAnchor/HorizontalAnchor/VerticalAnchor/Hand/ArmMoving
onready var camera = get_tree().get_root().get_node("Level/Others/Camera")
onready var claw_script = $ArmAnchor/HorizontalAnchor/VerticalAnchor/Hand/Sprite
onready var claw_closing_sound = $ArmAnchor/HorizontalAnchor/VerticalAnchor/Hand/ClawClosing
onready var delay_timer = $DelayTimer
onready var fake_player = $ArmAnchor/HorizontalAnchor/VerticalAnchor/Hand/SpriteAnchor/PlayerSprite
onready var tween = $Tween

var color_rect
var control
var extend = true
var gui
var player


func _ready():
	gui = get_tree().get_root().get_node("Level/Others/GUI")
	control = gui.get_node("Control")
	color_rect = control.get_node("ColorRect")


func _on_PlayerRemover_body_entered(_body):
	arm_player.play("WaverClaws")
	set_deferred("monitoring", false)
	
	GameTime.encourage_time()
	Global.player.stopped = true
	gui.flash()
	arm_moving_sound.playing = true
	tween.interpolate_property(arm, "global_position", null,
		Vector2(Global.player.global_position.x,
				Global.player.global_position.y - 192),
		0.1)
	tween.start()


func _on_Tween_tween_all_completed():
	if extend:
		extend = false
		claw_script.frame = 2
		claw_closing_sound.playing = true
		camera.target = null
		fake_player.visible = true
		fake_player.rotation_degrees = Global.player.get_node("Body").rotation_degrees
		GameTime.normalize_time()
		Global.player.global_position = Vector2(1000, 0)
		delay_timer.start()
	else:
		GameTime.in_game = false
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Actors/StatisticsList/StatsList.tscn")


func _on_DelayTimer_timeout():
	color_rect.color = Color(0, 0, 0, 1)
	tween.interpolate_property(control, "modulate", null, Color(1, 1, 1, 1), 1)
	tween.interpolate_property(arm, "global_position", null,
		Vector2(arm.global_position.x, arm.global_position.y - 192),
		1)
	tween.start()
