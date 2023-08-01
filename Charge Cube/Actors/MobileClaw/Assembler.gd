extends Area2D

enum Part { RAND, LEGS, ARMS}

export(Part) var add = Part.RAND

onready var rand = RandomNumberGenerator.new()


func _ready():
	rand.randomize()


func _on_Assembler_body_entered(body):
	if body.is_in_group("EnemyOff"):
		if add == Part.RAND:
			body.status = rand.randi_range(Part.RAND, Part.ARMS)
		else:
			body.status = add
