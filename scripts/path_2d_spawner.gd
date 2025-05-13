extends Path2D

var timer = 0
@export var spawnerTime = 0

var enemi1 = preload("res://scenes/enemi/scorpion.tscn") 
var enemi2 = preload("res://scenes/enemi/rat.tscn") 

func _ready() -> void:
	Player._init_ui()

func _process(delta: float) -> void:
	timer += delta
	
	if (timer > spawnerTime):
		var newEnemi = enemi1.instantiate()
		var newEnemi1 = enemi2.instantiate()
		add_child(newEnemi)
		add_child(newEnemi1)

		timer = 0
	
