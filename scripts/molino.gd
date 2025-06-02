extends Node2D

@export var damage = 12
@export var attack_interval := 1.2 
@export var price: float = 700
@export var escala: float = 0.5
@export var speed_reduction := 0.01  
@export var restore_speed := 0.01    


# Valores base para calcular mejoras
var base_damage := 12
var base_speed := 1500.0
var base_attack_speed := 1.2

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

var original_speeds = {}  
var can_place = true

func _ready():
	$attack_timer.wait_time = attack_interval
	set_process(true)
	if has_node("TurretMenu"):
		$TurretMenu.tower = self

func _process(_delta):
	if enemigos.size() >= 1 and can_attack:
		can_attack = false
		atq()

func atq():
	for enemy in enemigos:
		if !enemy.is_dead:
			# Aplicar daño
			enemy.get_damage(damage)
			
			# Reducir velocidad solo si es la primera vez qu   e entra
			if not original_speeds.has(enemy):
				original_speeds[enemy] = enemy.runSpeed
				enemy.runSpeed = max(0.01, enemy.runSpeed - speed_reduction)  

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		var enemy = area.get_parent()
		if not enemy in enemigos:
			enemigos.append(enemy)
			# Guardar velocidad original y reducir velocidad
			original_speeds[enemy] = enemy.runSpeed
			enemy.runSpeed = max(0.01, enemy.runSpeed - speed_reduction)

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		var enemy = area.get_parent()
		if enemy in enemigos:
			enemigos.erase(enemy)
			# Restaurar velocidad original si la tenemos guardada
			if original_speeds.has(enemy):
				enemy.runSpeed = original_speeds[enemy]
				original_speeds.erase(enemy)

func _on_attack_timer_timeout() -> void:
	can_attack = true


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
		damage = base_damage + (4 * upgrade_levels["damage"])
		update_menu_info()

func upgrade_speed():
	if upgrade_levels["speed"] >= MAX_SPEED_LEVEL:
		return
	
	var cost = speed_upgrade_cost * (upgrade_levels["speed"] + 1)
	if Player.player_gold >= cost:
		Player.player_gold -= cost
		refund += cost * sell_refund_percent
		upgrade_levels["speed"] += 1
		var new_interval = base_attack_speed - (0.08 * upgrade_levels["speed"])
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
		speed_reduction += 0.005
		update_menu_info()

func sell_tower():
	Player.player_gold += refund
	emit_signal("tower_sold", position)
	queue_free()
	Player.update_ui()


func get_save_data() -> Dictionary:
	return {
		"scene_path": "res://scenes/towers/molino.tscn",
		"position": position,
		"damage": damage,
		"speed_reduction":speed_reduction,
		"upgrade_levels": upgrade_levels,
		"attack_interval": attack_interval
	}
