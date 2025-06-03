extends Node

# Variables del jugador
var player_life = 100
var player_gold = 100000
var wave = 100
var dificulty = 1
var unlocked_towers: Array[String] 
var info : Dictionary

# Referencias UI
var hp_label
var gold_label
var wave_label
var damage_overlay

# Sistema de guardado
const SAVE_PATH := "user://game_save.dat"
const SAVE_VERSION := 1.0

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
	wave_label.text = "Day: " + str(wave)

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

# Funciones para guardado

func update_info():
	# Actualiza el diccionario info con los datos actuales del juego
	info = {
		"version": SAVE_VERSION,
		"player": {
			"life": player_life,
			"gold": player_gold
		},
		"progress": {
			"wave": wave,
			"dificulty": dificulty
		},
		"towers": get_towers_data()
	}

func get_towers_data() -> Array:
	var towers_data = []
	var towers = get_tree().get_nodes_in_group("torreta")
	
	for tower in towers:
		if tower.has_method("get_save_data"):
			towers_data.append(tower.get_save_data())
		else:
			push_warning("Torreta no tiene método get_save_data(): ", tower.name)
	
	return towers_data

func save_game() -> bool:
	update_info()  # Asegura que info esté actualizado
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Error al guardar: ", FileAccess.get_open_error())
		return false
	
	file.store_var(info)
	file.close()
	print("Juego guardado correctamente")
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No existe archivo de guardado")
		return false
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("Error al cargar: ", FileAccess.get_open_error())
		return false
	
	var loaded_info = file.get_var()
	file.close()
	
	# Verificar versión del guardado
	if loaded_info.get("version", 0) != SAVE_VERSION:
		push_warning("Versión de guardado diferente (actual: %s, guardado: %s)" % [
			SAVE_VERSION,
			loaded_info.get("version", 0)
		])
	
	# Restaurar datos del jugador
	player_life = loaded_info["player"].get("life", player_life)
	player_gold = loaded_info["player"].get("gold", player_gold)
	
	# Restaurar progreso
	wave = loaded_info["progress"].get("wave", wave)
	dificulty = loaded_info["progress"].get("dificulty", dificulty)
	
	# Actualizar UI
	update_ui()
	
	print("Partida cargada correctamente")
	return true
