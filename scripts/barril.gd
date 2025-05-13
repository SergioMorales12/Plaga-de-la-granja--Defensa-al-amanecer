extends Node2D

@export var damage = 50

@export var bulletSpeed := 1000.0
@export var bulletPierce := 1
@export var attack_interval := 2  
@export var escala: float = 0.8

var enemigos = []
var current_target = null
var can_attack = true

func _ready() -> void:
	$attack_timer.wait_time = attack_interval

func _process(_delta):
	if current_target and is_instance_valid(current_target) and current_target in enemigos and !current_target.is_dead:

		if can_attack:
			$AnimatedSprite2D.play("atq")
	else:
		$AnimatedSprite2D.play("idle")
		try_get_closest_target()

func attack():
	if current_target and is_instance_valid(current_target) and current_target in enemigos :
		
		var projectileScene = preload("res://scenes/towers/bullet_barril.tscn")
		var projectile = projectileScene.instantiate()
		projectile.damage = damage
		projectile.speed = bulletSpeed
		projectile.pierce = bulletPierce
		projectile.position = Vector2(0, -47.008) + position
		projectile.target = current_target.position
		get_parent().add_child(projectile)
		can_attack = false

func _on_attack_timer_timeout():
	can_attack = true


func try_get_closest_target():
	if !enemigos.is_empty():
		for enemigo in enemigos:
			if enemigo.progress > current_target.progress:
				print( "enemigo cambiado")
				current_target = enemigos

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


func _on_animated_sprite_2d_animation_finished() -> void:
	attack()
	$AnimatedSprite2D.play("idle")
