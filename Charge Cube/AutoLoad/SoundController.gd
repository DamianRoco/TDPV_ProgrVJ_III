extends Node

onready var audio_player = $Music
onready var tween = $Tween

var game_music = load("res://Assets/Music/Game.ogg")
var menu_music = load("res://Assets/Music/Menu.ogg")
var master_volume = AudioServer.get_bus_volume_db(0) setget set_master_volume
var stop_music = false


func get_sound_volume() -> float:
	return AudioServer.get_bus_volume_db(1)

func get_music_volume() -> float:
	return AudioServer.get_bus_volume_db(2)


func set_master_volume(new_value):
	master_volume = new_value
	AudioServer.set_bus_volume_db(0, master_volume)
	AudioServer.set_bus_mute(0, master_volume < -29.9)


func change_master_volume(volume_down = true):
	stop_music = volume_down
	tween.interpolate_property(self, "master_volume", null,
		-30 if volume_down else 0,
		0.5)
	tween.start()

func change_sound_volume(volume):
	AudioServer.set_bus_volume_db(1, volume)
	AudioServer.set_bus_mute(1, volume < -29.9)

func change_music_volume(volume):
	AudioServer.set_bus_volume_db(2, volume)
	AudioServer.set_bus_mute(2, volume < -29.9)


func play_game_music():
	if audio_player.stream == game_music:
		return
	audio_player.stream = game_music
	audio_player.play()
	change_master_volume(false)


func play_menu_music():
	audio_player.stream = menu_music
	audio_player.play()
	change_master_volume(false)


func _on_Tween_tween_all_completed():
	if stop_music:
		audio_player.stop()
