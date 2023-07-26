extends Position2D

export(int) var min_animation_speed = -10
export(int) var max_animation_speed = 3
export(bool) var active = true

onready var animation_player = $AnimationPlayer

var player


func _ready():
	if active:
		animation_player.play("Flow")


func _process(_delta):
	if is_instance_valid(player):
		if player.animation_tree.get_animation() == "Off":
			player.caught = false
			animation_player.set_speed_scale(max_animation_speed)
		else:
			player.global_position = $Sprite.global_position


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player") and active:
		Global.hidden_level = true
		
		active = false
		body.turn_off()
		player = body
		animation_player.set_speed_scale(min_animation_speed)
