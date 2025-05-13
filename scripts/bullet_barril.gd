extends Node2D

var target = null
var direction: Vector2
var speed: float = 0.0
var damage: float = 10
var pierce: int = 0
var time: float = 2.0
var previousTarget: Node = null
var impacted: bool = false  

func _process(delta):
	if target and not impacted:
		if not direction:
			direction = (target - position).normalized()
		position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	var obj = area.get_parent()
	if obj.is_in_group("enemi"):
		reached(obj)

func reached(target1):
	if target1.is_in_group("enemi") and target1 != previousTarget:
		previousTarget = target1
		pierce -= 1
		apply_explosion_damage()
		impacted = true 
		
func apply_explosion_damage():
	$AnimatedSprite2D.play("impact")
	for area in $ExplosionArea.get_overlapping_areas():
		var obj = area.get_parent()
		if obj.is_in_group("enemi"):
			obj.get_damage(damage)

func _on_timer_timeout() -> void:
	queue_free()

func _on_animation_finished() -> void:
	queue_free()
