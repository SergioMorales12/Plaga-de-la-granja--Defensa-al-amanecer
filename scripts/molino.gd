extends Node2D

@export var damage = 10
@export var attack_interval := 0.5   
@export var price: float = 700
@export var escala: float = 0.5
@export var speed_reduction := 0.01  
@export var restore_speed := 0.01    

var enemigos = []
var original_speeds = {}  
var can_attack = true
var can_place = true

func _ready():
	$attack_timer.wait_time = attack_interval
	set_process(true)

func _process(_delta):
	if enemigos.size() >= 1 and can_attack:
		can_attack = false
		atq()

func atq():
	for enemy in enemigos:
		if !enemy.is_dead:
			# Aplicar daño
			enemy.get_damage(damage)
			
			# Reducir velocidad solo si es la primera vez que entra
			if not original_speeds.has(enemy):
				original_speeds[enemy] = enemy.runSpeed
				enemy.runSpeed = max(0, enemy.runSpeed - speed_reduction)  

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		var enemy = area.get_parent()
		if not enemy in enemigos:
			enemigos.append(enemy)
			# Guardar velocidad original y reducir velocidad
			original_speeds[enemy] = enemy.runSpeed
			enemy.runSpeed = max(0, enemy.runSpeed - speed_reduction)

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		var enemy = area.get_parent()
		if enemy in enemigos:
			enemigos.erase(enemy)
			# Restaurar velocidad original si la tenemos guardada
			if original_speeds.has(enemy):
				enemy.runSpeed = original_speeds[enemy]
				original_speeds.erase(enemy)

func _on_attack_timer_timeout() -> void:
	can_attack = true
