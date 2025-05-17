extends Node

var player_life = 100
var player_gold = 1000
var wave = 1
var dificulty = 1
var info : Dictionary
var hp_label
var gold_label
var wave_label
var damage_overlay

func _ready():
	await get_tree().process_frame
	call_deferred("_init_ui")


func _init_ui():
	print_tree()

	hp_label = get_node_or_null("/root/Mapa/panel_torretas/Panel/Stats/Hp")
	gold_label = get_node_or_null("/root/Mapa/panel_torretas/Panel/Stats/Gold")
	wave_label = get_node_or_null("/root/Mapa/panel_torretas/Panel/Stats/Wave")
	damage_overlay = get_node_or_null("/root/Mapa/panel_torretas/DamageOverlay")  
	if damage_overlay:
		damage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	update_ui()
	

	
func reduce_player_life(amount):
	amount *= dificulty
	player_life -= amount
	player_life = max(player_life, 0)
	update_ui()

func add_player_gold(amount):
	amount *= dificulty
	player_gold += amount
	update_ui()

func update_ui():
	if not hp_label or not gold_label or not wave_label:
		print("UI no inicializada aún, se omite actualización")
		return

	hp_label.text = "HP: " + str(player_life)
	gold_label.text = "Gold: " + str(player_gold)
	wave_label.text = "Wave: " + str(wave)

	var hp_percent = clamp(float(player_life) / 100.0, 0.0, 1.0)
	var alpha = (1.0 - hp_percent) * 0.5

	if damage_overlay:
		var color = damage_overlay.color
		color.a = alpha
		damage_overlay.color = color

	if player_life <= 0:
		player_life = 100
		player_gold = 1000
		wave = 1
		Global.change_scene("res://scenes/main_menu.tscn")
