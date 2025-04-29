extends PathFollow2D

@export var runSpeed = 0.03
@export var damage = 10
@export var live = 500

func _ready():
	var area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 10
	collision_shape.shape = shape
	
	area.add_child(collision_shape)
	add_child(area)
	area.add_to_group("enemi")

func _process(delta: float) -> void:
	loop_movement(delta)
	var direction = rotation_degrees
	var animated_sprite = $AnimatedSprite2D
	print(direction)
	
	if direction >= -45 and direction < 45:
		animated_sprite.animation = "right"
		print("derecha")
	elif direction >= 45 and direction < 135:
		animated_sprite.animation = "down"
		print("abajo")
	elif direction >= 135 and direction < 225:
		animated_sprite.animation = "left"
		print("izquierda")
	else:
		animated_sprite.animation = "up"
		print("arriba ESPANIA")

	if progress_ratio >= 1.0:
		queue_free()

func loop_movement(delta: float) -> void:
	progress_ratio += runSpeed * delta

func get_damage(amount: float) -> void:
	live -= amount
	if live <= 0:
		queue_free()
