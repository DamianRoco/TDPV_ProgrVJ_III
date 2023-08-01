extends HSlider

enum { HUNDREDS, TENS, ONES }

export(bool) var sound_slider = true

onready var area_fill = $AreaFill
onready var numbers = $Numbers
onready var num_pos = [Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)]


func _ready():
	if sound_slider:
		value = (SoundController.get_sound_volume() + 30) * 2
	else:
		value = (SoundController.get_music_volume() + 30) * 2
	area_fill.region_rect.size.x = (value * 80) / 100


func set_numbers(value):
	if value > 99:
		numbers.set_cellv(num_pos[ONES], 0)
		numbers.set_cellv(num_pos[TENS], 0)
		numbers.set_cellv(num_pos[HUNDREDS], 1)
	else:
		numbers.set_cellv(num_pos[HUNDREDS], -1)
		if value > 9:
			numbers.set_cellv(num_pos[ONES], int(value) % 10)
			numbers.set_cellv(num_pos[TENS], value / 10)
		else:
			numbers.set_cellv(num_pos[ONES], value)
			numbers.set_cellv(num_pos[TENS], -1)


func _on_HSlider_value_changed(value):
	area_fill.region_rect.size.x = (value * 80) / 100
	set_numbers(value)
	if sound_slider:
		SoundController.change_sound_volume(value / 2 - 30)
	else:
		SoundController.change_music_volume(value / 2 - 30)


func _on_HSlider_mouse_exited():
	release_focus()
