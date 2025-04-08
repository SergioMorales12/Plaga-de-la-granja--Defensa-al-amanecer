extends Node2D

@export var hp = 0
@export var damage = 0
@export var speed = 0

@export var bulletSpeed := 200.0
@export var bulletPierce := 1

func _ready():
	$Area2D.monitoring = true
	

func attack():
	if damage : #is_instance_valid(current_target):
		var projectileScene := preload("res://scenes/towers/bullet_espanta.tscn")
		var projectile := projectileScene.instantiate()
		#projectile.bullet_type = Data.turrets[turret_type]["bullet"]
		projectile.damage = damage
		projectile.speed = bulletSpeed
		projectile.pierce = bulletPierce
		#Globals.projectilesNode.add_child(projectile)
		projectile.position = position
		#projectile.target = current_target.position
	else:
		pass
		#try_get_closest_target()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		print("Es un enemigo")
		$sleep.visible = false
		$active.visible = true


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		var overlapping_bodies = $Area2D.get_overlapping_areas()
		var enemy_present = false
		for b in overlapping_bodies:
			if b.is_in_group("enemi"):
				enemy_present = true
				break
		if not enemy_present:
			$sleep.visible = true
			$active.visible = false
