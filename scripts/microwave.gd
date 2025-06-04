extends Node2D

@export var damage = 15
@export var attack_interval := 0.6  
@export var price: float = 900
@export var escala: float = 1

# Valores base para calcular mejoras
var base_damage := 15
var base_attack_speed := 0.6

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
const MIN_ATTACK_INTERVAL := 0.15  # Límite mínimo para el intervalo de ataque

var enemigos = []
var can_attack = false
var upgrade_levels = {
	"damage": 0,
	"speed": 0,
	"special": 0
}

signal tower_sold(position)

var rayos_activos = false  

func _ready():
	set_process(true)
	$attack_timer.wait_time = attack_interval
	$AnimatedSprite2D.play("idle")
	if has_node("TurretMenu"):
		$TurretMenu.tower = self

func _process(delta):
	if enemigos.size() > 0 and can_attack:
		var objetivo_valido = false
		for e in enemigos:
			if not e.is_dead:
				objetivo_valido = true
				break

		if objetivo_valido:
			can_attack = false
			await get_tree().create_timer(0.2).timeout
			atq()

	if rayos_activos:
		for e in enemigos:
			if not e.is_dead:
				e.get_damage(damage * delta)

func atq():
	$AnimatedSprite2D.play("atq")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		var enemigo = area.get_parent()
		if enemigo not in enemigos:
			enemigos.append(enemigo)

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("enemi"):
		enemigos.erase(area.get_parent())

func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "atq":
		$AnimatedSprite2D.play("idle")
		$AnimatedSprite2D2.play("rayos")
		rayos_activos = true

func _on_animation_finished() -> void:
	if $AnimatedSprite2D2.animation == "rayos":
		rayos_activos = false
		$attack_timer.start()

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
		damage = base_damage + (5 * upgrade_levels["damage"])
		update_menu_info()

func upgrade_speed():
	if upgrade_levels["speed"] >= MAX_SPEED_LEVEL:
		return
	
	var cost = speed_upgrade_cost * (upgrade_levels["speed"] + 1)
	if Player.player_gold >= cost:
		Player.player_gold -= cost
		refund += cost * sell_refund_percent
		upgrade_levels["speed"] += 1
		var new_interval = base_attack_speed - (0.1 * upgrade_levels["speed"])
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
		attack_interval -= 0.005
		update_menu_info()

func sell_tower():
	Player.player_gold += refund
	emit_signal("tower_sold", position)
	queue_free()
	Player.update_ui()


func get_save_data() -> Dictionary:
	return {
		"scene_path": "res://scenes/towers/microwave.tscn",
		"position": position,
		"damage": damage,
		"upgrade_levels": upgrade_levels,
		"attack_interval": attack_interval
	}

func load_save_data(data: Dictionary) -> void:
	if data.has("position"):
		var pos = data["position"]
		if typeof(pos) == TYPE_STRING:
			var cleaned = pos.replace("(", "").replace(")", "")
			var parts = cleaned.split(",")
			if parts.size() == 2:
				position = Vector2(parts[0].to_float(), parts[1].to_float())
		elif typeof(pos) == TYPE_VECTOR2:
			position = pos
	if data.has("damage"):
		damage = data["damage"]
	
	if data.has("attack_interval"):
		attack_interval = data["attack_interval"]
	
	if data.has("upgrade_levels"):
		upgrade_levels = data["upgrade_levels"].duplicate()
