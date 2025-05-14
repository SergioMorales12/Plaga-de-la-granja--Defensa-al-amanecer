extends Node2D

@export var damage = 10

@export var bulletSpeed := 2000.0
@export var bulletPierce := 1
@export var attack_interval := 1  # Intervalo de ataque en segundos
@export var escala: float = 1

var enemigos = []
var current_target = null
var can_attack = false




func _process(_delta):
	if current_target and current_target in enemigos and !current_target.is_dead:
		if can_attack:
			attack()
	else:
		try_get_closest_target()

func attack():
	if current_target and is_instance_valid(current_target) and current_target in enemigos :
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


func try_get_closest_target():
	$AnimatedSprite2D.play("sleep")
	if !enemigos.is_empty() :
		current_target = enemigos.back()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		enemigos.append(area.get_parent())
		if not current_target:
			current_target = area.get_parent()

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		enemigos.erase(area.get_parent())
		if current_target == area.get_parent():
			var enemy_present = false
			for body in enemigos:
				if body.is_in_group("enemi"):
					enemy_present = true
					current_target = body
					break
			if not enemy_present:
				current_target = null
				set_process(true)


func _on_touch_screen_button_pressed() -> void:
	pass # Replace with function body.
