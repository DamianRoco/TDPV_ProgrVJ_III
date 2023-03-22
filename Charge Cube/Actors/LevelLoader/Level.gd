extends Node2D

const explosion_scene = preload("res://Actors/InvertedExplosion.tscn")
const player_scene = preload("res://Actors/Player/Player.tscn")

export var enemy_path : String = ""
export var show_colliders = false

onready var enemy_scene = load(enemy_path)
onready var enemy_container = get_parent().get_node("Enemies")
onready var others = get_parent().get_node("Others")
onready var camera = others.get_node("Camera")
onready var gui = others.get_node("GUI")

var enemy_instance
var explosion_instance
var player_instance


func _ready():
	if show_colliders:
		get_tree().set_debug_collisions_hint(true)
	
	if not Global.spawn_player:
		Global.spawn_player = true
		player_instance = others.get_node("Player")
		camera.target = player_instance
		gui.player = player_instance
		camera.global_position = player_instance.global_position
	else:
		if Global.level_start:
			Global.spawn_point = camera.global_position
			Global.level_start = false
		instance_enemy()
		instance_explosion()


func _process(_delta):
	if is_instance_valid(explosion_instance) and explosion_instance.emitting == false:
		instance_player(enemy_instance.global_position)
		gui.flash()
		enemy_instance.queue_free()
		explosion_instance.queue_free()
#	if Input.is_action_just_pressed("ui_accept"):
#		if Input.is_key_pressed(KEY_SPACE):
#			var _error = get_tree().change_scene("res://Levels/Other.tscn")


func instance_explosion():
	yield(get_tree().create_timer(1.5), 'timeout')
	explosion_instance = explosion_scene.instance()
	enemy_instance.add_child(explosion_instance)
	explosion_instance.emitting = true


func instance_enemy():
	enemy_instance = enemy_scene.instance()
	enemy_container.add_child(enemy_instance)
	
	enemy_instance.pause_mode = Node.PAUSE_MODE_PROCESS
	enemy_instance.global_position = Global.spawn_point
	camera.target = enemy_instance
	camera.global_position = Global.spawn_point


func instance_player(position):
	player_instance = player_scene.instance()
	others.add_child(player_instance)
	
	player_instance.global_position = position
	camera.target = player_instance
	gui.player = player_instance
