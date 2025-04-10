extends PathFollow2D

@export var runSpeed = 0.0
@export var damage = 0
@export var live = 0

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
	
	if progress_ratio >= 1.0:
		queue_free()

func loop_movement(delta):
	progress_ratio += runSpeed * delta

func get_damage(amount: float) -> void:
	live -= amount
	if live <= 0:
		queue_free()
