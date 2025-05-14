extends Path2D

@export var spawner_time: float = 2.0

var enemi1 = preload("res://scenes/enemi/scorpion.tscn") 
var enemi2 = preload("res://scenes/enemi/rat.tscn") 
var enemi3 = preload("res://scenes/enemi/cuervo.tscn") 
var enemi4 = preload("res://scenes/enemi/spider.tscn") 

var spawner_timer: Timer

func _ready() -> void:
	print("Path2D listo")

	# Crear y añadir el Timer
	spawner_timer = Timer.new()
	spawner_timer.wait_time = spawner_time
	spawner_timer.one_shot = false
	spawner_timer.autostart = false  # <- NO autostart todavía
	add_child(spawner_timer)

	# Conectar la señal
	spawner_timer.timeout.connect(_on_timer_timeout)

	# Iniciar el timer de forma segura una vez en el árbol
	call_deferred("_start_timer")

	# UI
	if Player:
		Player._init_ui()

func _start_timer():
	# Este método se ejecuta *después* de que el nodo esté en escena
	if spawner_timer.is_inside_tree():
		spawner_timer.start()
	else:
		await get_tree().process_frame
		spawner_timer.start()

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
