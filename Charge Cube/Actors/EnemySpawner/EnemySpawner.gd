extends VisibilityNotifier2D

export var enemy_path : String = ""

onready var enemy_scene = load(enemy_path)

var enemy_instance
var summon = false


func _process(_delta):
	if summon and not is_instance_valid(enemy_instance):
		summon = false
		instance_enemy()


func instance_enemy():
	enemy_instance = enemy_scene.instance()
	add_child(enemy_instance)
	
	enemy_instance.global_position = global_position


func _on_EnemySpawner_screen_entered():
	summon = true


func _on_EnemySpawner_screen_exited():
	summon = false
