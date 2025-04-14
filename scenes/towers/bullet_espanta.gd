extends Node2D

var target = null
var direction: Vector2

var speed: float = 0.0
var damage: float = 10
var pierce: int = 10
var time: float = 1.0

func _process(delta):
	if target:
		if not direction:
			direction = (target - position).normalized()
		position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	var obj = area.get_parent()
	if obj.is_in_group("enemi"):
		pierce -= 1
		obj.get_damage(damage)
	if pierce == 0:
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
