extends PathFollow2D

@export var runSpeed = 0.03
@export var damage = 10
@export var live = 50

var previous_position: Vector2
var is_dead: bool = false

func _ready():
	previous_position = global_position
	var area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 10
	collision_shape.shape = shape
	
	area.add_child(collision_shape)
	add_child(area)
	area.add_to_group("enemi")

func _process(delta: float) -> void:
	if is_dead:
		return
	
	loop_movement(delta)
	var animated_sprite = $AnimatedSprite2D
	var direction = get_direction()
	
	if live > 0:
		animated_sprite.play(direction)
	
	previous_position = global_position
	
	if progress_ratio >= 1.0:
		queue_free()

func loop_movement(delta: float) -> void:
	progress_ratio += runSpeed * delta

func get_direction() -> String:
	var velocity = global_position - previous_position
	if abs(velocity.x) > abs(velocity.y):
		if velocity.x > 0:
			return "right"
		else:
			return "left"
	else:
		if velocity.y > 0:
			return "down"
		else:
			return "up"

func get_damage(amount: float) -> void:
	live -= amount
	var animated_sprite = $AnimatedSprite2D
	
	if live <= 0:
		is_dead = true
		animated_sprite.stop()
		print("muerto")
		animated_sprite.play("dieLeft")
		$Timer.start()

func _on_timeout() -> void:
	print("out")
	queue_free()
