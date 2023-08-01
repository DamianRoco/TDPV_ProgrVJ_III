extends TileMap

enum Stats { BROKEN_BLOCKS, BROKEN_CLAWS, ENEMY_DEATHS, PLAYER_DEATHS, TIME }

export(int) var total_characters = 1
export(Vector2) var unit_pos = Vector2.ZERO
export(Stats) var stat

var current_pos = 0
var current_value = 0
var value


func _ready():
	match stat:
		Stats.BROKEN_BLOCKS:
			value = Statistics.broken_blocks
		Stats.BROKEN_CLAWS:
			value = Statistics.broken_claws
		Stats.ENEMY_DEATHS:
			value = Statistics.enemy_deaths
		Stats.PLAYER_DEATHS:
			value = Statistics.player_deaths
		Stats.TIME:
			value = GameTime.get_time()
	
	set_value_limit()
	for i in total_characters:
		set_cellv(get_tile_pos(), get_value())
		if stat == Stats.TIME and (i == 1 or i == 3):
			current_pos += 2


func get_value():
	var num = value
	for _i in current_value:
		num = num / 10
	num = int(num) % 10
	current_value += 1
	return num


func get_tile_pos():
	var tile_pos = Vector2(unit_pos.x - current_pos, unit_pos.y)
	current_pos += 1
	return tile_pos


func set_value_limit():
	var num = 9
	for _i in range(total_characters - 1):
		num = num * 10 + 9
	if value > num:
		value = num
		set_cellv(Vector2(unit_pos.x - total_characters, unit_pos.y), 10)
