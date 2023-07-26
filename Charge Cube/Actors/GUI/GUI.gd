extends CanvasLayer

signal screen_off(hidden_level_entrance)

export(int) var min_value : int = 13
export(float) var random_shake_strength : float = 5.0
export(float) var shake_decay_rate: float = 10.0
export(bool) var is_hidden_level : bool = false

onready var animation_player = $AnimationPlayer
onready var energy_bar = get_node("EnergyBar")
onready var life_bar = get_node("LifeBar")
onready var rand = RandomNumberGenerator.new()

var shake_strength : float = 0.0
var shake : bool = false


func _ready():
	$Control.modulate.a = 1
	$Control/ColorRect.color = Color.black
	rand.randomize()
	animation_player.play("LevelFadeIn")


func _process(delta):
	if is_instance_valid(Global.player):
		if Global.player.is_alive():
			life_bar.value = Global.player.health + min_value
			change_energy_value()
		elif life_bar.value > 0:
			life_bar.value = 0
		
		if shake:
			shake_strength = lerp(shake_strength, 0, shake_decay_rate * delta)
			offset = get_random_offset()
		else:
			offset = Vector2.ZERO


func get_random_offset():
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)


func change_energy_value():
	var value
	if (not Global.player.dash.delay_timer.is_stopped() or
		not Global.player.dash.can_dash):
		energy_bar.modulate = Color.gray
		value = Global.player.dash.delay_timer.time_left * 100
	else:
		energy_bar.modulate = Color.white
		value = Global.player.aiming_timer * 100
	energy_bar.value = 100 - value


func flash():
	animation_player.play("Flash")


func level_fade_out():
	animation_player.play("LevelFadeOut")


func apply_random_shake():
	shake_strength = random_shake_strength
	shake = true


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"LevelFadeIn":
			if (is_instance_valid(Global.terrain_loader) and
				not Global.save_terrain):
				Global.terrain_loader.load_map()
			get_tree().paused = false
		"RedFadeOut":
			get_tree().paused = true


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"LevelFadeIn":
			if is_instance_valid(Global.player):
				energy_bar.visible = true
				life_bar.visible = true
		"LevelFadeOut":
			if is_hidden_level:
				emit_signal("screen_off", Global.HiddenLevel.COME)
			elif is_instance_valid(Global.player) and Global.player.health < 0:
				emit_signal("screen_off", Global.HiddenLevel.GO)
			else:
				emit_signal("screen_off", Global.HiddenLevel.NONE)
		"RedFadeOut":
			if is_hidden_level:
				emit_signal("screen_off", Global.HiddenLevel.COME)
			else:
				Global.terrain_loader.save_map()
				get_tree().call_deferred("reload_current_scene")
		"Flash":
			energy_bar.visible = true
			life_bar.visible = true


func _on_FadeOutTimer_timeout():
	match Global.player.health:
		0:
			animation_player.play("RedFadeOut")
		_:
			animation_player.play("LevelFadeOut")


func _on_LifeBar_value_changed(value):
	if value == 0:
		if Global.player.health != 0:
			$FadeOutTimer.wait_time = 1
		$FadeOutTimer.start()
	elif value > min_value:
		apply_random_shake()
