extends Path2D

var timer = 0
@export var spawnerTime = 0

var enemi1 = preload("res://scenes/enemi/scorpion.tscn") 

func _process(delta: float) -> void:
	timer += delta
	
	if (timer > spawnerTime):
		var newEnemi = enemi1.instantiate()
		add_child(newEnemi)
		timer = 0
	
