tool
extends Node2D

export var max_levels = 7
export var max_stages = 7
export var show_colliders = false
export var second_entry = Vector2.ZERO


func _ready():
	if Engine.editor_hint:
		return
	
	GameTime.in_game = true
	SoundController.play_game_music()
	Global.enemy_folder = get_parent().get_node("Enemies")
	Global.projectile_folder = get_parent().get_node("Projectiles")
	if show_colliders:
		get_tree().set_debug_collisions_hint(true)
	
	spawn_player()


func _process(_delta):
	if Engine.editor_hint:
		update()


func _draw():
	if Engine.editor_hint:
		var color = Color(1.0, 0.5, 0.5, 1.0)
		var points = []
		var center = second_entry * 16
		center += Vector2(8, 8)
		points.append(Vector2(center.x - 7.5, center.y - 7.5))
		points.append(Vector2(center.x - 7.5, center.y + 7.5))
		points.append(Vector2(center.x + 7.5, center.y + 7.5))
		points.append(Vector2(center.x + 7.5, center.y - 7.5))
		draw_colored_polygon(points, color)


func spawn_player():
	var others = get_parent().get_node("Others")
	
	var camera = others.get_node("Camera")
	var checkpoints = get_parent().get_node("Checkpoints")
	var player_instance = others.get_node("Player")
	
	if not Global.spawn_player and Global.hidden_level == Global.HiddenLevel.NONE:
		Global.spawn_player = true
		
		if Global.go_to == Global.Level.PREVIOUS:
			var spawn_num = checkpoints.get_child_count() - 1
			Global.active_checkpoint_name = checkpoints.get_child(spawn_num).name
			player_instance.global_position = second_entry * Global.tile_size
		else:
			Global.active_checkpoint_name = "EnemySpawner"
			if Global.level.is_equal_approx(Vector2(1, 1)):
				player_instance.get_node("Body").rotation_degrees -= 90
		
		Global.player = player_instance
		camera.global_position = player_instance.global_position
		camera.target = player_instance
	else:
		if is_instance_valid(player_instance):
			player_instance.queue_free()
		
		var spawn
		if Global.hidden_level != Global.HiddenLevel.NONE:
			if Global.hidden_level == Global.HiddenLevel.COME:
				Global.hidden_level = Global.HiddenLevel.NONE
			spawn = checkpoints.get_node("HiddenLevelSpawner")
		else:
			spawn = checkpoints.get_node(Global.active_checkpoint_name)
		
		camera.global_position = spawn.global_position
		spawn.initialize(others)


func _on_GUI_screen_off(hidden_level_entrance):
	var level_num = Global.get_level_name(hidden_level_entrance, max_levels)
	var level_scene = "res://Levels/" + level_num + ".tscn"
	# warning-ignore:return_value_discarded
	get_tree().change_scene(level_scene)
