extends Node2D

@export var hp = 0
@export var damage = 0
@export var speed = 0

func _ready():
	$Area2D.monitoring = true

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
