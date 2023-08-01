extends Node

const END_VALUE = 1

var in_game = false
var slow_time = false
var time


func _ready():
	Engine.time_scale = END_VALUE
	AudioServer.global_rate_scale = END_VALUE


func _process(delta):
	if in_game:
		time += delta


func get_time() -> Vector3:
	var aux_time = time
	var hours = int(aux_time / 3600)
	aux_time -= hours * 3600
	var minutes = int(aux_time / 60)
	aux_time -= minutes * 60
	aux_time += (hours * 10000) + (minutes * 100)
	return aux_time


func encourage_time():
	Engine.time_scale = 0.1
	AudioServer.global_rate_scale = 1.9
	slow_time = true


func normalize_time():
	Engine.time_scale = END_VALUE
	AudioServer.global_rate_scale = END_VALUE
	slow_time = false
