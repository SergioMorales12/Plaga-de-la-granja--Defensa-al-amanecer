extends Node2D

@export var damage = 0
@export var speed = 0
@export var range = 100

@export var bulletSpeed := 900.0
@export var bulletPierce := 1
@export var attack_interval := 0.5  # Intervalo de ataque en segundos

var enemigos = []
var current_target = null
var can_attack = true

func _ready():
	$Area2D.monitoring = true
	set_process(true)
	var attack_timer = $attack_timer
	attack_timer.wait_time = attack_interval
	attack_timer.one_shot = false
	attack_timer.start()

func _process(_delta):
	if current_target and is_instance_valid(current_target) and current_target in enemigos:
		if can_attack:
			attack()
	else:
		try_get_closest_target()

func attack():
	if current_target and is_instance_valid(current_target) and current_target in enemigos:
		print(current_target)
		$AnimatedSprite2D.play("Atq")
		var projectileScene = preload("res://scenes/towers/bullet_espanta.tscn")
		var projectile = projectileScene.instantiate()
		projectile.damage = damage
		projectile.speed = bulletSpeed
		projectile.pierce = bulletPierce
		projectile.position = Vector2(-30, -16) + position
		projectile.target = current_target.position
		get_parent().add_child(projectile)
		can_attack = false

func _on_attack_timer_timeout():
	can_attack = true

var draw_range = true

func _draw():
	if draw_range:
		draw_circle(Vector2(0, 0), range, Color(0.24, 0.8, 0.65, 0.66), false, 1, true)

func try_get_closest_target():
	$AnimatedSprite2D.play("sleep")
	var overlapping_bodies = $Area2D.get_overlapping_areas()
	for body in overlapping_bodies:
		if body.is_in_group("enemi"):
			current_target = body
			break

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		enemigos.append(area.get_parent())
		if not current_target:
			current_target = area.get_parent()

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		enemigos.erase(area.get_parent())
		if current_target == area.get_parent():
			var overlapping_bodies = $Area2D.get_overlapping_areas()
			var enemy_present = false
			for body in enemigos:
				if body.is_in_group("enemi"):
					enemy_present = true
					current_target = body
					break
			if not enemy_present:
				current_target = null
				set_process(true)
