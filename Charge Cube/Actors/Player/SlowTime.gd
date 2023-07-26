extends Node

const END_VALUE = 1

var is_active = false


func _ready():
	Engine.time_scale = END_VALUE
	AudioServer.global_rate_scale = END_VALUE

func start():
	Engine.time_scale = 0.1
	AudioServer.global_rate_scale = 1.9
	is_active = true

func end():
	Engine.time_scale = END_VALUE
	AudioServer.global_rate_scale = END_VALUE
	is_active = false
