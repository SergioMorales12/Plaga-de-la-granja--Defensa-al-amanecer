extends Node2D

@export var damage = 10
@export var attack_interval := 0.5  
@export var escala: float = 1

var enemigos = []
var can_attack = true
var rayos_activos = false  

func _ready():
	set_process(true)
	$attack_timer.wait_time = attack_interval
	$AnimatedSprite2D.play("idle")

func _process(delta):
	if enemigos.size() > 0 and can_attack:
		var objetivo_valido = false
		for e in enemigos:
			if not e.is_dead:
				objetivo_valido = true
				break

		if objetivo_valido:
			can_attack = false
			await get_tree().create_timer(0.2).timeout
			atq()

	if rayos_activos:
		for e in enemigos:
			if not e.is_dead:
				e.get_damage(damage * delta)

func atq():
	$AnimatedSprite2D.play("atq")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		var enemigo = area.get_parent()
		if enemigo not in enemigos:
			enemigos.append(enemigo)

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		enemigos.erase(area.get_parent())

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "atq":
		$AnimatedSprite2D.play("idle")
		$AnimatedSprite2D2.play("rayos")
		rayos_activos = true

func _on_animation_finished() -> void:
	if $AnimatedSprite2D2.animation == "rayos":
		rayos_activos = false
		$attack_timer.start()

func _on_attack_timer_timeout() -> void:
	can_attack = true
