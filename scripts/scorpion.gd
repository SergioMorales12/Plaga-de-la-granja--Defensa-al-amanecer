extends PathFollow2D

var dificulty = Player.dificulty
signal enemy_died

@export var runSpeed = 0.03
@export var damage = 10  
@export var live = 110
@export var reward = 90

var previous_position: Vector2
var is_dead: bool = false
var direction = null


func _ready():
	previous_position = global_position

func _process(delta: float) -> void:
	if is_dead:
		return
	
	loop_movement(delta)
	var animated_sprite = $AnimatedSprite2D
	direction = get_direction()
	
	if live > 0:
		animated_sprite.play(direction)
	
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
		else:
			return "left"
	else:
		if velocity.y > 0:
			return "down"
		else:
			return "up"

func get_damage(amount: float):
	live -= amount
	var animated_sprite = $AnimatedSprite2D
	
	if live <= 0:
		is_dead = true
		animated_sprite.stop()
		Player.add_player_gold(reward)
		emit_signal("enemy_died")
		animated_sprite.play("die"+direction)
		$Timer.start()

func _on_timeout() -> void:
	queue_free()
