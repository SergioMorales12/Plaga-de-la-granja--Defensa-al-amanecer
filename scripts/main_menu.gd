extends Control

@onready var menu_button: OptionButton = $Buttons/VBoxContainer/MenuButton
@onready var start_button: Button = $Buttons/VBoxContainer/startButton
@onready var delete_button: Button = $Buttons/VBoxContainer/deleteButton

var selected_save: String = "new_game"

func _ready():
	load_save_games()
	process_mode = Node.PROCESS_MODE_ALWAYS
	update_button_states()

func load_save_games():
	if not is_instance_valid(menu_button):
		push_error("MenuButton no es una instancia válida")
		return
	menu_button.clear()
	
	# Opción de nueva partida siempre disponible
	menu_button.add_item("Nueva partida")
	menu_button.set_item_metadata(0, "new_game")
	
	# Cargar partidas existentes
	if not FileAccess.file_exists(Global.FILE_PATH):
		return
	
	var file = FileAccess.open(Global.FILE_PATH, FileAccess.READ)
	if not file:
		push_error("Error al abrir archivo de guardado")
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var parse_result = JSON.parse_string(json_text)
	if parse_result is Dictionary:
		# Convertir el diccionario a un array de entries para ordenar
		var saves = []
		for key in parse_result:
			saves.append({"key": key, "value": parse_result[key]})
		
		# Ordenar partidas por fecha (más recientes primero)
		saves.sort_custom(func(a, b): 
			var time_a = a.value.get("timestamp", "")
			var time_b = b.value.get("timestamp", "")
			return time_a > time_b
		)
		
		for save in saves:
			var name = save.key
			var day = save.value.get("current_day", 1)
			var timestamp = save.value.get("timestamp", "").substr(0, 10) # Solo la fecha
			menu_button.add_item("Partida %s (Día %d - %s)" % [name, day, timestamp])
			menu_button.set_item_metadata(menu_button.get_item_count() - 1, name)
			
func update_button_states():
	# Actualizar texto del botón según selección
	if selected_save == "new_game":
		start_button.text = "NUEVA PARTIDA"
		delete_button.disabled = true
	else:
		start_button.text = "CONTINUAR PARTIDA"
		delete_button.disabled = false

func _on_exit_button_pressed():
	get_tree().quit()

func _on_start_button_pressed():
	print(selected_save)
	if selected_save == "new_game":
		# Crear nueva partida con nombre único
		var save_name = "partida_%d" % (int(Time.get_unix_time_from_system()) % 10000)
		Global.current_save_name = save_name
		Player.reset_to_defaults()
		Global.change_scene("res://scenes/mapa.tscn")
	else:
		# Cargar partida existente
		var success = await Global.load_game_named(selected_save)
		if success:
			Global.current_save_name = selected_save
		else:
			selected_save = "new_game"
			update_button_states()


func _on_menu_button_item_selected(index: int):
	selected_save = menu_button.get_item_metadata(index)
	update_button_states()

func _on_delete_button_pressed():
	if selected_save == "new_game":
		return
	
	# Confirmación antes de borrar
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.dialog_text = "¿Eliminar la partida '%s' permanentemente?" % selected_save
	confirm_dialog.confirmed.connect(_delete_confirmed)
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()

func _delete_confirmed():
	if FileAccess.file_exists(Global.FILE_PATH):
		var file = FileAccess.open(Global.FILE_PATH, FileAccess.READ)
		var json_text = file.get_as_text()
		file.close()
		
		var all_saves = JSON.parse_string(json_text)
		if all_saves is Dictionary and all_saves.has(selected_save):
			all_saves.erase(selected_save)
			
			var save_file = FileAccess.open(Global.FILE_PATH, FileAccess.WRITE)
			save_file.store_string(JSON.stringify(all_saves, "\t"))
			save_file.close()
			
			# Actualizar lista
			load_save_games()
			selected_save = "new_game"
			update_button_states()


func _on_logout_button_pressed() -> void:
	Firebase.Auth.logout()
	Global.change_scene("res://scenes/login.tscn")
