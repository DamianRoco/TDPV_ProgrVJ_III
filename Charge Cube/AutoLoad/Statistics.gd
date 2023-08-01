extends Node

var variable_limit : int = 99999
var broken_blocks : int
var broken_claws : int
var enemy_deaths : int
var player_deaths : int


func _ready():
	load_stats()


func load_stats():
	var save_file := File.new()
	if save_file.file_exists("user://save_stats.save"):
		# warning-ignore:return_value_discarded
		save_file.open("user://save_stats.save", File.READ)
		broken_blocks = save_file.get_var()
		broken_claws = save_file.get_var()
		enemy_deaths = save_file.get_var()
		player_deaths = save_file.get_var()
		GameTime.time = save_file.get_var()
		save_file.close()
	else:
		broken_blocks = 0
		broken_claws = 0
		enemy_deaths = 0
		player_deaths = 0
		GameTime.time = 0


func reset_stats():
	broken_blocks = 0
	broken_claws = 0
	enemy_deaths = 0
	player_deaths = 0
	GameTime.time = 0
	
	var dir = Directory.new()
	var save_file := File.new()
	if not save_file.file_exists("user://save_map.save"):
		dir.remove("user://save_map.save")
	if save_file.file_exists("user://save_stats.save"):
		dir.remove("user://save_stats.save")
	
	Global.reset()


func save_stats():
	var save_file := File.new()
	# warning-ignore:return_value_discarded
	save_file.open("user://save_stats.save", File.WRITE)
	save_file.store_var(broken_blocks)
	save_file.store_var(broken_claws)
	save_file.store_var(enemy_deaths)
	save_file.store_var(player_deaths)
	save_file.store_var(GameTime.time)
	save_file.close()
