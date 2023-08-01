extends Node2D

func animation_start():
	$AnimationPlayer.play("StartExplosion")
	Statistics.enemy_deaths += 1
