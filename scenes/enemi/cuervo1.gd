extends PathFollow2D

@export var runSpeed = 0.0
@export var damage = 0
@export var live = 0

func _process(delta: float) -> void:
	loop_movement(delta)
	
	if not loop and progress_ratio >= 1.0:
		queue_free()

func loop_movement(delta):
	progress_ratio += runSpeed * delta
	
