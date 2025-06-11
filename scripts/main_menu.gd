extends Control

@onready var menu_button: OptionButton = $Buttons/VBoxContainer/MenuButton
@onready var start_button: Button = $Buttons/VBoxContainer/startButton
@onready var delete_button: Button = $Buttons/VBoxContainer/deleteButton
@onready var logout_button: Button = $Buttons/VBoxContainer/logoutButton
@onready var sync_button: Button = $Buttons/VBoxContainer/syncButton
@onready var status_label: Label = $StatusLabel
@onready var player_name_label: Label = $PlayerNameLabel

var player_id := ""
var selected_save: String = "new_game"
var is_syncing := false

func _ready() -> void:
	update_status("Cargando...")
	setup_authentication()
	await load_save_games()
	update_button_states()
	update_status("Listo")


func setup_authentication() -> void:
	Global.get_userid()
	player_id = Global.player_id
	sync_button.visible = player_id != "guest_user"
	

func update_status(message: String) -> void:
	status_label.text = message
	print(message)

func load_save_games() -> void:
	update_status("Cargando partidas...")
	menu_button.clear()
	menu_button.add_item("Nueva partida")
	menu_button.set_item_metadata(0, "new_game")
	selected_save = "new_game"

	var saves = await get_available_saves()
	populate_menu_with_saves(saves)
	update_status("Partidas cargadas: " + str(menu_button.item_count - 1))


func get_available_saves() -> Dictionary:
	if player_id == "guest_user":
		return Global.load_local_saves()
		
	var api_saves = await Global.load_all_cloud_saves()
	if api_saves.is_empty():
		print("API VACIA")
		return Global.load_local_saves()
	return api_saves

func populate_menu_with_saves(saves: Dictionary) -> void:
	print("Loaded saves: ", saves.keys())
	if saves.is_empty():
		update_status("No hay partidas guardadas")
		return

	var sorted_saves = []
	for save_name in saves:
		var save_data = saves[save_name]
		
		# Verificar si los datos están anidados (caso de Firestore)
		if typeof(save_data) == TYPE_DICTIONARY and save_data.has("fields"):
			save_data = Global.convert_from_firestore_format(save_data["fields"])
		
		# Asegurarse que save_data es un diccionario
		if typeof(save_data) != TYPE_DICTIONARY:
			push_error("Datos de guardado inválidos para: " + save_name)
			continue
			
		sorted_saves.append({
			"name": save_name,
			"data": save_data
		})
	
	# Ordenar partidas por timestamp (más reciente primero)
	sorted_saves.sort_custom(func(a, b):
		var a_time = a.data.get(Global.TIMESTAMP_KEY, 0) if typeof(a.data) == TYPE_DICTIONARY else 0
		var b_time = b.data.get(Global.TIMESTAMP_KEY, 0) if typeof(b.data) == TYPE_DICTIONARY else 0
		return b_time > a_time
	)

	for save in sorted_saves:
		var save_name = save["name"]
		var save_data = save["data"]
		
		# Verificación adicional de tipo
		if typeof(save_data) != TYPE_DICTIONARY:
			push_error("Datos inválidos para partida: " + save_name)
			continue
			
		# Manejar timestamps faltantes
		var timestamp = save_data.get(Global.TIMESTAMP_KEY, 0) if typeof(save_data) == TYPE_DICTIONARY else 0
		var time_dict = Time.get_date_dict_from_unix_time(timestamp)
		
		# Formatear fecha
		var date_str = "%02d/%02d/%d" % [time_dict.day, time_dict.month, time_dict.year]
		
		# Crear texto para el menú
		var item_text = "%s (Día %d - %s)" % [
			save_name,
			save_data.get("days", 1) if typeof(save_data) == TYPE_DICTIONARY else 1,
			date_str
		]

		# Añadir al menú
		var idx = menu_button.get_item_count()
		menu_button.add_item(item_text)
		menu_button.set_item_metadata(idx, save_name)


func sort_saves_by_timestamp(saves: Dictionary) -> Array:
	var saves_array = []
	for save_name in saves:
		saves_array.append({
			"name": save_name,
			"data": saves[save_name]
		})
	
	saves_array.sort_custom(func(a, b):
		return b.data.get(Global.TIMESTAMP_KEY, 0) - a.data.get(Global.TIMESTAMP_KEY, 0)
	)
	return saves_array

func add_save_to_menu(save_name: String, save_data: Dictionary) -> void:
	var time_dict = Time.get_date_dict_from_unix_time(save_data.get(Global.TIMESTAMP_KEY, 0))
	var date_str = "%02d/%02d/%d " % [
		time_dict.day, time_dict.month, time_dict.year
	]
	
	var item_text = "%s (Día %d - %s)" % [
		save_name, save_data.get("days", 1), date_str
	]
	
	var idx = menu_button.get_item_count()
	menu_button.add_item(item_text)
	menu_button.set_item_metadata(idx, save_name)

func update_button_states() -> void:
	start_button.text = "NUEVA PARTIDA" if selected_save == "new_game" else "CONTINUAR"
	delete_button.disabled = selected_save == "new_game"

func _on_menu_button_item_selected(idx: int) -> void:
	selected_save = menu_button.get_item_metadata(idx)
	update_button_states()

func _on_start_button_pressed() -> void:
	if selected_save == "new_game":
		await start_new_game()
	else:
		await continue_existing_game()

func start_new_game() -> void:
	update_status("Creando nueva partida...")
	var save_name = generate_save_name()
	Global.current_save_name = save_name
	Player.reset_to_defaults()
	Player.update_data()
	Global.change_scene("res://scenes/mapa.tscn")
	await Global.save_game_named(save_name)
	update_status("Partida creada: " + save_name)

func generate_save_name() -> String:
	var timestamp = int(Time.get_unix_time_from_system())
	var suffix = timestamp % 10000
	return Global.DEFAULT_SAVE_NAME_PREFIX + "%04d" % suffix

func continue_existing_game() -> void:
	update_status("Cargando partida...")
	var success = await Global.load_game_named(selected_save)
	if success:
		update_status("Partida cargada: " + selected_save)
		Global.change_scene("res://scenes/mapa.tscn")
	else:
		update_status("Error cargando partida")
		selected_save = "new_game"
		update_button_states()

func _on_delete_button_pressed() -> void:
	if selected_save == "new_game":
		return
		
	var dialog = ConfirmationDialog.new()
	dialog.title = "Confirmar eliminación"
	dialog.dialog_text = "¿Eliminar partida '%s'?" % selected_save
	dialog.confirmed.connect(_on_delete_confirmed)
	add_child(dialog)
	dialog.popup_centered()

func _on_delete_confirmed() -> void:
	update_status("Eliminando partida...")
	var success = await Global.delete_game_named(selected_save)
	if success:
		await load_save_games()
		selected_save = "new_game"
		update_button_states()
		update_status("Partida eliminada")
	else:
		update_status("Error eliminando partida")

func _on_sync_button_pressed() -> void:
	if is_syncing:
		return
		
	is_syncing = true
	update_status("Sincronizando con la nube...")
	var success = await Global.sync_saved_games()
	if success:
		await load_save_games()
		update_status("Sincronización completada")
	else:
		update_status("Error en sincronización")
	is_syncing = false

func _on_logout_button_pressed() -> void:
	if Firebase and Firebase.Auth.auth:
		Firebase.Auth.logout()
	Global.change_scene("res://scenes/login.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
