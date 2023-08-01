extends Node2D

onready var explosion = $Explosion
var emitting : bool

func _ready():
	emitting = true
	$Explosion.emitting = true
	$Explosion2.emitting = true
	$Explosion3.emitting = true
	$Explosion4.emitting = true
	$InvertedElectricExplosion.playing = true


func _process(_delta):
	if emitting and not explosion.emitting:
		emitting = false
