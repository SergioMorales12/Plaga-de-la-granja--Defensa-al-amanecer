extends CanvasLayer

@onready var damage_button: Button = $Panel/Damage
@onready var speed_button: Button = $Panel/Speed
@onready var special_button: Button = $Panel/Special
@onready var sell_button: Button = $Panel/Sell
@onready var close_button: Button = $Panel/Close

# Constantes para los máximos niveles (deben coincidir con los de la torreta)
const MAX_DAMAGE_LEVEL := 10
const MAX_SPEED_LEVEL := 8
const MAX_ATTACK_SPEED_LEVEL := 7

var tower: Node2D = null

func _ready():
	$Panel.visible = false


func update_info(damage_cost: int, speed_cost: int, special_cost: int, sell_refund: int, levels: Dictionary):
	# Daño
	if damage_cost == -1:
		damage_button.text = "Daño MAX (%d/%d)" % [levels["damage"], MAX_DAMAGE_LEVEL]
		damage_button.disabled = true
	else:
		damage_button.text = "Daño (%d/%d)\n$%d" % [levels["damage"], MAX_DAMAGE_LEVEL, damage_cost]
		damage_button.disabled = false
	
	# Velocidad de ataque
	if speed_cost == -1:
		speed_button.text = "Vel. Ataque MAX (%d/%d)" % [levels["speed"], MAX_SPEED_LEVEL]
		speed_button.disabled = true
	else:
		speed_button.text = "Vel. Ataque (%d/%d)\n$%d" % [levels["speed"], MAX_SPEED_LEVEL, speed_cost]
		speed_button.disabled = false
	
	# Especial
	if special_cost == -1:
		special_button.text = "Especial MAX (%d/%d)" % [levels["special"], MAX_ATTACK_SPEED_LEVEL]
		special_button.disabled = true
	else:
		special_button.text = "Especial (%d/%d)\n$%d" % [levels["special"], MAX_ATTACK_SPEED_LEVEL, special_cost]
		special_button.disabled = false

	
	# Vender
	sell_button.text = "Vender $%d" % sell_refund

func _on_damage_upgrade_pressed():
	if tower:
		tower.upgrade_damage()

func _on_speed_upgrade_pressed():
	if tower:
		tower.upgrade_speed()

func _on_special_upgrade_pressed():
	if tower:
		tower.upgrade_special()

func _on_sell_pressed():
	if tower:
		tower.sell_tower()
		$Panel.visible = false

func _on_close_pressed():
	$Panel.visible = false
