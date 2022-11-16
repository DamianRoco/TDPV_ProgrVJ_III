extends CanvasLayer

onready var player : KinematicBody2D = get_tree().get_nodes_in_group("player")[0]


func _ready():
	$AnimationPlayer.play("fade_in")
	$TextureProgress.max_value = player.health + $TextureProgress.min_value


func _process(_delta):
	if is_instance_valid(player):
		$TextureProgress.value = player.health + $TextureProgress.min_value


func _on_AnimationPlayer_animation_started(anim_name):
	match anim_name:
		"fade_out":
			get_tree().paused = true
			


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"fade_in":
			get_tree().paused = false
		"fade_out":
			get_tree().call_deferred("reload_current_scene")


func _on_TextureProgress_value_changed(value):
	if value <= $TextureProgress.min_value:
		$AnimationPlayer.play("fade_out")
