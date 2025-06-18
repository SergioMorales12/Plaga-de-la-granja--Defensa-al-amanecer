extends Node2D

@export var attack_interval := 10.0
@export var price: float = 1000
@export var escala: float = 1
@export var hp: float = 5
@export var gold: float = 200

# Valores base para calcular mejoras
var base_hp := 5
var base_gold := 200
var base_attack_speed := 10.0

# Costes de mejoras
var hp_upgrade_cost := 100
var speed_upgrade_cost := 100
var gold_upgrade_cost := 125
var sell_refund_percent := 0.7  # 70% del precio al vender

# Valor de venta
var refund = price * sell_refund_percent

# Límites de mejoras
const MAX_DAMAGE_LEVEL := 10
const MAX_SPEED_LEVEL := 8
const MAX_SPECIAL_LEVEL := 7
const MIN_ATTACK_INTERVAL := 0.2  

var can_attack = true
var upgrade_levels = {
	"damage": 0,
	"speed": 0,
	"special": 0
}
var is_preview = false
signal tower_sold(position)

func _ready():
	$attack_timer.wait_time = attack_interval
	$attack_timer.start()

	$AnimatedSprite2D.play("idle")


func _on_attack_timer_timeout():
	if can_attack and !is_preview:
		var action = randi() % 2
		match action:
			0:
				heal()
			1:
				generate_money()


func heal():
	$AnimatedSprite2D.play("hp")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("idle")
	Player.player_life += hp
	Player.update_ui()
	$attack_timer.start()


func generate_money():
	$AnimatedSprite2D.play("money")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("idle")
	Player.player_gold += gold
	Player.update_ui()
	$attack_timer.start()


func get_save_data() -> Dictionary:
	return {
		"scene_path": "res://scenes/towers/plant.tscn",
		"position": position,
		"hp": hp,
		"gold": gold,
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
	if data.has("gold"):
		gold = data["gold"]
	
	if data.has("hp"):
		hp = data["hp"]
	
	if data.has("attack_interval"):
		attack_interval = data["attack_interval"]
	
	if data.has("upgrade_levels"):
		upgrade_levels = data["upgrade_levels"].duplicate()

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
			hp_upgrade_cost * (upgrade_levels["damage"] + 1) if upgrade_levels["damage"] < MAX_DAMAGE_LEVEL else -1,
			speed_upgrade_cost * (upgrade_levels["speed"] + 1) if upgrade_levels["speed"] < MAX_SPEED_LEVEL else -1,
			gold_upgrade_cost * (upgrade_levels["special"] + 1) if upgrade_levels["special"] < MAX_SPECIAL_LEVEL else -1,
			refund,
			upgrade_levels
		)
		Player.update_ui()

func upgrade_damage():
	if upgrade_levels["damage"] >= MAX_DAMAGE_LEVEL:
		return
	
	var cost = hp_upgrade_cost * (upgrade_levels["damage"] + 1)
	if Player.player_gold >= cost:
		Player.player_gold -= cost
		refund += cost * sell_refund_percent
		upgrade_levels["damage"] += 1
		hp = base_hp + (4 * upgrade_levels["damage"])
		update_menu_info()

func upgrade_speed():
	if upgrade_levels["speed"] >= MAX_SPEED_LEVEL:
		return
	
	var cost = speed_upgrade_cost * (upgrade_levels["speed"] + 1)
	if Player.player_gold >= cost:
		Player.player_gold -= cost
		refund += cost * sell_refund_percent
		upgrade_levels["speed"] += 1
		attack_interval = max(MIN_ATTACK_INTERVAL, base_attack_speed - (0.08 * upgrade_levels["speed"]))
		$attack_timer.wait_time = attack_interval
		update_menu_info()

func upgrade_special():
	if upgrade_levels["special"] >= MAX_SPECIAL_LEVEL:
		return
	
	var cost = gold_upgrade_cost * (upgrade_levels["special"] + 1)
	if Player.player_gold >= cost:
		Player.player_gold -= cost
		refund += cost * sell_refund_percent
		upgrade_levels["special"] += 1
		gold += 25
		update_menu_info()

func sell_tower():
	Player.player_gold += refund
	emit_signal("tower_sold", position)
	queue_free()
	Player.update_ui()
