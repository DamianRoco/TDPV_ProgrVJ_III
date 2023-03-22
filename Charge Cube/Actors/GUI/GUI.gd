extends CanvasLayer

signal screen_off

export(int) var min_value = 13
export(float) var random_shake_strength: float = 5.0
export(float) var shake_decay_rate: float = 10.0

onready var animation_player = $AnimationPlayer
onready var health_bar = get_node("TextureProgress")
onready var rand = RandomNumberGenerator.new()

var player
var shake_strength : float = 0.0
var shake : bool = false


func _ready():
	rand.randomize()
	animation_player.play("LevelFadeIn")


func _process(delta):
	if is_instance_valid(player):
		if player.is_alive():
			health_bar.value = player.health + min_value
		elif health_bar.value > 0:
			health_bar.value = 0
		
		shake_strength = lerp(shake_strength, 0, shake_decay_rate * delta)
		var shake_offset = Vector2.ZERO
		if shake:
			shake_offset = get_random_offset()
		offset = shake_offset


func get_random_offset():
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)


func flash():
	animation_player.play("Flash")


func level_fade_out():
	animation_player.play("LevelFadeOut")


func apply_random_shake():
	shake_strength = random_shake_strength
	shake = true


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"RedFadeOut":
			get_tree().paused = true


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"LevelFadeIn":
			if is_instance_valid(player):
				health_bar.visible = true
			get_tree().paused = false
		"LevelFadeOut":
			emit_signal("screen_off")
		"RedFadeOut":
			get_tree().call_deferred("reload_current_scene")
		"Flash":
			health_bar.visible = true


func _on_FadeOutTimer_timeout():
	match player.health:
		0:
			animation_player.play("RedFadeOut")
		_:
			animation_player.play("LevelFadeOut")


func _on_TextureProgress_value_changed(value):
	if value == 0:
		if player.health != 0:
			$FadeOutTimer.wait_time = 1
		$FadeOutTimer.start()
	elif value > min_value:
		apply_random_shake()
