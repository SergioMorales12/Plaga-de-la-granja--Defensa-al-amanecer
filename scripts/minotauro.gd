extends PathFollow2D

var dificulty = Player.dificulty
signal enemy_died

@export var runSpeed = 0.003
@export var damage = 100000000000  
@export var live = 11000
@export var reward = 10000

var previous_position: Vector2
var is_dead: bool = false
var direction: String = "right"

func _ready():
	previous_position = global_position
	$ProgressBar.max_value = live
	$ProgressBar.value = live

func _process(delta: float) -> void:
	if is_dead:
		return
	
	loop_movement(delta)
	
	var animated_sprite = $AnimatedSprite2D
	direction = get_direction()
	
	if direction == "right":
		animated_sprite.flip_h = true
	elif direction == "left":
		animated_sprite.flip_h = false
	
	previous_position = global_position
	
	if progress_ratio >= 0.99:
		Player.reduce_player_life(damage)
		emit_signal("enemy_died")
		queue_free()

func loop_movement(delta: float) -> void:
	progress_ratio += runSpeed * delta

func get_direction() -> String:
	var velocity = global_position - previous_position
	if abs(velocity.x) > abs(velocity.y):
		if velocity.x > 0:
			return "right"
		elif velocity.x < 0:
			return "left"
	return direction  

func get_damage(amount: float):
	live -= amount
	$ProgressBar.value -= amount
	var animated_sprite = $AnimatedSprite2D
	
	if live <= 0:
		is_dead = true
		animated_sprite.stop()
		Player.add_player_gold(reward)
		emit_signal("enemy_died")
		$Timer.start()

func _on_timeout() -> void:
	queue_free()
