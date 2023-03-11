extends Area2D

onready var is_open : bool = false


func _on_Checkpoint_body_entered(body):
	if body.is_in_group("Player") and not is_open:
		is_open = true
		$AnimationPlayer.play("Open")
		Global.spawn_point = Vector2(global_position.x, global_position.y - 7.5)
