tool
extends VisibilityNotifier2D

enum Enemies { ENEMY_OFF, KEY, HAMMER, RIVETER, MAGNET }

export(Enemies) var enemy_type setget set_enemy_type
export var spawn_enemy : bool = true
export var spawn_player : bool = false

onready var enemy_scene = load(enemy_paths[enemy_type])
onready var ground = $Ground

var camera
var enemy_instance
var explosion_instance
var explosion_scene
var gui
var others
var player_scene
var summon_player = false

var enemy_paths = [
	"res://Actors/Enemy/Basic/EnemyOff.tscn",
	"res://Actors/Enemy/Basic/Key.tscn",
	"res://Actors/Enemy/Basic/Hammer.tscn",
	"res://Actors/Enemy/Basic/Riveter.tscn",
	"res://Actors/Enemy/Basic/Magnet.tscn"
]


func _ready():
	if not Engine.editor_hint:
		camera = get_tree().get_root().get_node("Level/Others/Camera")
		if is_instance_valid(enemy_instance):
			enemy_instance.queue_free()


func initialize(others_node):
	explosion_scene = preload("res://Actors/Particles/InvertedElectricExplosion.tscn")
	player_scene = preload("res://Actors/Player/Player.tscn")
	
	summon_player = true
	others = others_node
	gui = others.get_node("GUI")


func _process(_delta):
	if Engine.editor_hint:
		return
	if is_instance_valid(explosion_instance) and not explosion_instance.emitting:
		enemy_instance.damage_ctrl(enemy_instance.health)
		enemy_instance.get_node("HeadCollision").disabled = true
		enemy_instance.get_node("FeetCollision").disabled = true
		instance_player(enemy_instance.global_position)
		explosion_instance.queue_free()


func set_enemy_type(type):
	enemy_type = type
	if Engine.editor_hint:
		if is_instance_valid(enemy_instance):
			enemy_instance.queue_free()
		enemy_instance = load(enemy_paths[enemy_type]).instance()
		add_child(enemy_instance)


func instance_enemy():
	if spawn_enemy or summon_player:
		enemy_instance = enemy_scene.instance()
		add_child(enemy_instance)
		
		var pos = Vector2(global_position.x, global_position.y + check_ground())
		enemy_instance.global_position = pos
		if global_position.x < camera.global_position.x:
			enemy_instance.flip()
		
		if summon_player:
			summon_player = false
			camera.target = enemy_instance
			enemy_instance.get_node("BodyExplosion/Body").visible = false
			$ExplosionTimer.start()


func instance_player(position):
	var player_instance = player_scene.instance()
	others.add_child(player_instance)
	
	player_instance.global_position = position
	Global.player = player_instance
	camera.target = player_instance
	gui.flash()


func check_ground() -> int:
	var length = 16
	ground.cast_to.y = length
	ground.force_raycast_update()
	while not ground.is_colliding():
		if length > 90:
			var pos = Vector2(global_position.x, global_position.y + 16)
			var tile_pos = Global.terrain.world_to_map(pos)
			Global.terrain.set_cellv(tile_pos, 0)
			return 0
		else:
			length += 16
			ground.cast_to.y = length
			ground.force_raycast_update()
			if (ground.is_colliding() and
				ground.get_collider().is_in_group("Electricity")):
				var pos = Vector2(global_position.x, global_position.y + length)
				var tile_pos = Global.terrain.world_to_map(pos)
				Global.terrain.set_cellv(tile_pos, 3)
	return length - 16


func _on_EnemySpawner_screen_entered():
	if not is_instance_valid(enemy_instance):
		instance_enemy()


func _on_EnemySpawner_screen_exited():
	if spawn_player:
		Global.active_checkpoint_name = name


func _on_ExplosionTimer_timeout():
	explosion_instance = explosion_scene.instance()
	enemy_instance.add_child(explosion_instance)
