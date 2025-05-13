extends Path2D

@export var spawner_time: float = 2.0  # Tiempo entre oleadas

var enemi1 = preload("res://scenes/enemi/scorpion.tscn") 
var enemi2 = preload("res://scenes/enemi/rat.tscn") 
var enemi3 = preload("res://scenes/enemi/cuervo.tscn") 
var enemi4 = preload("res://scenes/enemi/spider.tscn") 

func _ready() -> void:
	print(1)
	if Player:
		Player._init_ui()

func _on_timer_timeout() -> void:
	spawn_enemies()

func spawn_enemies():
	var new_enemi1 = enemi1.instantiate()
	var new_enemi2 = enemi2.instantiate()
	var new_enemi3 = enemi3.instantiate()
	var new_enemi4 = enemi4.instantiate()

	add_child(new_enemi1)
	add_child(new_enemi2)
	add_child(new_enemi3)
	add_child(new_enemi4)
