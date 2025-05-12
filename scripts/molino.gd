extends Node2D

@export var damage = 10
@export var attack_interval := 0.5  # Intervalo de ataque en segundos
@export var escala: float = 0.5

var enemigos = []
var can_attack = true
var can_place = true

func _ready():
	set_process(true)

func _process(_delta):
	if enemigos.size() >= 1:
		if can_attack:
			for i in enemigos:
				if !i.is_dead:
					can_attack = false
					atq()

func atq():
	if enemigos.size() >= 1:
		for i in enemigos:
			i.get_damage(damage)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		enemigos.append(area.get_parent())

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		enemigos.erase(area.get_parent())

func _on_attack_timer_timeout() -> void:
	can_attack = true
