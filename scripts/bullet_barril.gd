extends Node2D

var target = null
var direction: Vector2

var speed: float = 0.0
var damage: float = 10
var pierce: int = 0
var time: float = 1.0
var previousTarget

func _process(delta):
	if target:
		if not direction:
			direction = (target - position).normalized()
		position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	var obj = area.get_parent()
	if obj.is_in_group("enemi"):
		reached(obj)

func reached(target1):
	if target1.is_in_group("enemi") and target1 != previousTarget:
		previousTarget = target
		pierce -= 1
		target1.get_damage(damage)
		$AnimatedSprite2D.play("impact")
	if pierce < 1:
		queue_free()
	if pierce <= 0:
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()


func _on_animation_finished() -> void:
	queue_free()
