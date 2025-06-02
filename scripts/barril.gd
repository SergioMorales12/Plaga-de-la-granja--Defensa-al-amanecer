extends Node2D

@export var damage = 50
@export var bulletSpeed := 1500.0
@export var bulletPierce := 1
@export var attack_interval := 1.8  
@export var price: float = 800
@export var escala: float = 0.8

# Valores base para calcular mejoras
var base_damage := 60
var base_speed := 1500.0
var base_attack_speed := 2.0

# Costes de mejoras
var damage_upgrade_cost := 50
var speed_upgrade_cost := 50
var special_upgrade_cost := 75
var sell_refund_percent := 0.7  # 70% del precio al vender

# Valor de venta
var refund = price * sell_refund_percent

# Límites de mejoras
const MAX_DAMAGE_LEVEL := 10
const MAX_SPEED_LEVEL := 8
const MAX_SPECIAL_LEVEL := 7
const MIN_ATTACK_INTERVAL := 0.2  # Límite mínimo para el intervalo de ataque

var enemigos = []
var current_target = null
var can_attack = false
var upgrade_levels = {
	"damage": 0,
	"speed": 0,
	"special": 0
}

signal tower_sold(position)

func _ready() -> void:
	$attack_timer.wait_time = attack_interval
	if has_node("TurretMenu"):
		$TurretMenu.tower = self

func _process(_delta):
	if current_target and is_instance_valid(current_target) and current_target in enemigos and !current_target.is_dead:

		if can_attack:
			$AnimatedSprite2D.play("atq")
	else:
		$AnimatedSprite2D.play("idle")
		try_get_closest_target()

func attack():
	if current_target and is_instance_valid(current_target) and current_target in enemigos :
		
		var projectileScene = preload("res://scenes/towers/bullet_barril.tscn")
		var projectile = projectileScene.instantiate()
		projectile.damage = damage
		projectile.speed = bulletSpeed
		projectile.pierce = bulletPierce
		projectile.position = Vector2(0, -47.008) + position
		projectile.target = current_target.position
		get_parent().add_child(projectile)
		can_attack = false

func _on_attack_timer_timeout():
	can_attack = true


func try_get_closest_target():
	if !enemigos.is_empty():
		for enemigo in enemigos:
			if enemigo.progress > current_target.progress:
				print( "enemigo cambiado")
				current_target = enemigo

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		enemigos.append(area.get_parent())
		if not current_target:
			current_target = area.get_parent()

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		enemigos.erase(area.get_parent())
		if current_target == area.get_parent():
			var enemy_present = false
			for body in enemigos:
				if body.is_in_group("enemi"):
					enemy_present = true
					current_target = body
					break
			if not enemy_present:
				current_target = null
				set_process(true)


func _on_animated_sprite_2d_animation_finished() -> void:
	attack()
	$AnimatedSprite2D.play("idle")



# Funciones de mejoras

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggle_menu()

func toggle_menu():
	if has_node("TurretMenu"):
		var menu = $TurretMenu/Panel
		menu.visible = not menu.visible
		Player.update_ui()
		update_menu_info()

func update_menu_info():
	if has_node("TurretMenu"):
		$TurretMenu.update_info(
			damage_upgrade_cost * (upgrade_levels["damage"] + 1) if upgrade_levels["damage"] < MAX_DAMAGE_LEVEL else -1,
			speed_upgrade_cost * (upgrade_levels["speed"] + 1) if upgrade_levels["speed"] < MAX_SPEED_LEVEL else -1,
			special_upgrade_cost * (upgrade_levels["special"] + 1) if upgrade_levels["special"] < MAX_SPECIAL_LEVEL else -1,
			refund,
			upgrade_levels
		)
		Player.update_ui()

func upgrade_damage():
	if upgrade_levels["damage"] >= MAX_DAMAGE_LEVEL:
		return
	
	var cost = damage_upgrade_cost * (upgrade_levels["damage"] + 1)
	if Player.player_gold >= cost:
		Player.player_gold -= cost
		refund += cost * sell_refund_percent
		upgrade_levels["damage"] += 1
		damage = base_damage + (6 * upgrade_levels["damage"])
		update_menu_info()

func upgrade_speed():
	if upgrade_levels["speed"] >= MAX_SPEED_LEVEL:
		return
	
	var cost = speed_upgrade_cost * (upgrade_levels["speed"] + 1)
	if Player.player_gold >= cost:
		Player.player_gold -= cost
		refund += cost * sell_refund_percent
		upgrade_levels["speed"] += 1
		var new_interval = base_attack_speed - (0.15 * upgrade_levels["speed"])
		attack_interval = max(MIN_ATTACK_INTERVAL, new_interval)
		if attack_interval <= 0.0:
			attack_interval = MIN_ATTACK_INTERVAL
			
		$attack_timer.wait_time = attack_interval
		update_menu_info()

func upgrade_special():
	if upgrade_levels["special"] >= MAX_SPECIAL_LEVEL:
		return
	
	var cost = special_upgrade_cost * (upgrade_levels["special"] + 1)
	if Player.player_gold >= cost:
		Player.player_gold -= cost
		refund += cost * sell_refund_percent
		upgrade_levels["special"] += 1
		bulletSpeed += 200
		update_menu_info()

func sell_tower():
	Player.player_gold += refund
	emit_signal("tower_sold", position)
	queue_free()
	Player.update_ui()


func get_save_data() -> Dictionary:
	return {
		"scene_path": "res://scenes/towers/barril.tscn",
		"position": position,
		"damage": damage,
		"bulletSpeed": bulletSpeed,
		"upgrade_levels": upgrade_levels,
		"attack_interval": attack_interval
	}
