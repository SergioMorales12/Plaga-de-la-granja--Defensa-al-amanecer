extends Node

const TIMESTAMP_KEY := "timestamp"
const DEFAULT_SAVE_NAME_PREFIX := "partida_"
const MAX_LOCAL_BACKUPS := 3

var HTTP_HEADERS := ["Content-Type: application/json", "Access-Control-Allow-Origin: *"]
var FILE_PATH := "user://save_games.json"  
var map_select_container: Node2D
var current_scene_path: String = ""
var current_save_name: String
var API_URL = "https://firestore.googleapis.com/v1/projects/juegotwf/databases/(default)/documents/games"
var player_id := ""
var header = ["Content-Type: application/json"]

var volume_db: float = 0.0


func _ready() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume_db)


# Sistema de autenticación mejorado
func get_userid() -> void:
	if Firebase and Firebase.Auth:
		if Firebase.Auth.auth and Firebase.Auth.auth.localid:
			player_id = Firebase.Auth.auth.localid
			print("✅ ID del jugador (logueado):", player_id)
			return
	
	player_id = "guest_user"
	print("🔒 Usuario invitado")

# Sistema de escenas mejorado
func change_scene(new_scene_path: String) -> void:
	if new_scene_path == current_scene_path:
		return
		
	current_scene_path = new_scene_path
	get_tree().call_deferred("change_scene_to_file", new_scene_path)
	print("Cambiando a escena:", new_scene_path)

func restart() -> void:
	if map_select_container != null:
		get_tree().reload_current_scene()
		print("Reiniciando mapa:", map_select_container.get_path())
	else:
		push_error("No hay mapa cargado para reiniciar")

func restart_scene() -> void:
	if current_scene_path != "":
		get_tree().change_scene_to_file(current_scene_path)
		print("Reiniciando escena actual:", current_scene_path)
	else:
		push_error("No hay escena cargada para reiniciar")

func change_map(map_path: String) -> void:
	if map_select_container:
		map_select_container.queue_free()
	
	var new_map = load(map_path)
	if new_map:
		map_select_container = new_map.instantiate()
		get_tree().current_scene.add_child(map_select_container)
		print("Mapa cambiado a:", map_path)
	else:
		push_error("No se pudo cargar el mapa:", map_path)

# Sistema de guardado mejorado
func save_game_named(save_name: String) -> bool:
	get_userid()
	current_save_name = save_name
	
	if not validate_player_data():
		return false
	
	var save_data = prepare_save_data(save_name)
	var success_local = save_local(save_name, save_data)
	
	if not success_local:
		return false
	
	if player_id != "guest_user":
		return await save_to_cloud(save_name, save_data)
	
	return true

func validate_player_data() -> bool:
	if not Player.data:
		push_error("Datos del jugador no inicializados")
		return false
		
	var required = ["gold", "life", "days"]
	for key in required:
		if not Player.data.has(key):
			push_error("Falta dato requerido: " + key)
			return false
			
	return true

func prepare_save_data(save_name: String) -> Dictionary:
	return {
		save_name:{
			"life": int(Player.data.life),
			"gold": int(Player.data.gold),
			"days": int(Player.data.days),
			"unlocked_towers": Player.data.unlocked_towers,
			"difficulty": Player.data.dificulty,
			"towers": Player.data.towers,
			TIMESTAMP_KEY: Time.get_unix_time_from_system()}
		
	}

func save_local(save_name: String, data: Dictionary) -> bool:
	# Crear backup primero
	create_backup()
	
	var all_saves = load_local_saves()
	all_saves[save_name] = data
	
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Error abriendo archivo para guardar")
		return false
		
	file.store_string(JSON.stringify(all_saves, "\t"))
	file.close()
	print("✅ Guardado local exitoso:", save_name)
	return true

func create_backup() -> void:
	if not FileAccess.file_exists(FILE_PATH):
		return
		
	var backup_dir = "user://backups/"
	DirAccess.make_dir_recursive_absolute(backup_dir)
	
	# Rotar backups (mantener solo los 3 más recientes)
	var backups = []
	for file in DirAccess.get_files_at(backup_dir):
		if file.begins_with("save_games_backup_"):
			backups.append(file)
	
	backups.sort()
	while backups.size() >= MAX_LOCAL_BACKUPS:
		var oldest = backups.pop_front()
		DirAccess.remove_absolute(backup_dir + oldest)
	
	# Crear nuevo backup
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var backup_path = backup_dir + "save_games_backup_" + timestamp + ".json"
	DirAccess.copy_absolute(FILE_PATH, backup_path)

func save_to_cloud(save_name: String, data: Dictionary) -> bool:
	# Use PATCH method for upsert (update or create)
	var http = create_http_request()
	var request_url = API_URL + "/" + player_id
	var body = JSON.stringify({
		"fields": convert_to_firestore_format(data)
	})
	# Add query parameter to update all fields
	request_url += "?updateMask.fieldPaths="
	var fields = data.keys()
	for i in fields.size():
		request_url += fields[i]
		if i < fields.size() - 1:
			request_url += "&updateMask.fieldPaths="

	var error = http.request(request_url, header, HTTPClient.METHOD_PATCH, body)

	if error != OK:
		push_error("Error en petición HTTP: " + str(error))
		return false
		
	var result = await http.request_completed
	var response = process_http_response(result, "guardar")
	
	if response.success:
		print("✅ Guardado en nube exitoso:", save_name)
		return true
	else:
		push_error("❌ Error guardando en nube")
		return false

func convert_to_firestore_format(data: Dictionary) -> Dictionary:
	var firestore_data = {}
	
	for key in data.keys():
		var value = data[key]
		
		if typeof(value) == TYPE_INT:
			firestore_data[key] = { "integerValue": str(value) }
		elif typeof(value) == TYPE_FLOAT:
			firestore_data[key] = { "doubleValue": str(value) }
		elif typeof(value) == TYPE_STRING:
			firestore_data[key] = { "stringValue": value }
		elif typeof(value) == TYPE_ARRAY:
			var array_values = []
			for item in value:
				array_values.append({ "stringValue": str(item) }) # Ajusta esto si tus arrays son complejos
			firestore_data[key] = { "arrayValue": { "values": array_values } }
		elif typeof(value) == TYPE_DICTIONARY:
			firestore_data[key] = { "mapValue": { "fields": convert_to_firestore_format(value) } }
	
	return firestore_data


# Sistema de carga mejorado
func load_game_named(save_name: String) -> bool:
	get_userid()
	current_save_name = save_name
	
	var save_data = await get_save_data(save_name)
	if save_data.is_empty():
		return false
		
	return apply_save_data(save_data)

func get_save_data(save_name: String) -> Dictionary:
	if player_id == "guest_user":
		return load_local_save(save_name)
	else:
		var cloud_data = await load_cloud_save(save_name)
		if not cloud_data.is_empty():
			return cloud_data
		return load_local_save(save_name)

func load_local_save(save_name: String) -> Dictionary:
	var all_saves = load_local_saves()
	return all_saves.get(save_name, {})

func load_local_saves() -> Dictionary:
	if not FileAccess.file_exists(FILE_PATH):
		return {}
		
	var file = FileAccess.open(FILE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var parsed = JSON.parse_string(content)
	return parsed if parsed is Dictionary else {}

func load_cloud_save(save_name: String) -> Dictionary:
	var http = create_http_request()
	var request_url = API_URL + "/" + player_id
	
	var error = http.request(request_url, header, HTTPClient.METHOD_GET)
	
	if error != OK:
		push_error("Error en petición HTTP: " + str(error))
		return {}
		
	var result = await http.request_completed
	var response = process_http_response(result, "cargar")
	
	if not response.success:
		return {}
		
	var document = JSON.parse_string(response.body)
	if not document or not document.has("fields"):
		push_error("Formato de respuesta inválido")
		return {}

	var all_data = convert_from_firestore_format(document["fields"])

	if all_data.has(save_name):
		return all_data[save_name]
	
	push_error("No se encontró la partida en la nube: " + save_name)
	return {}

func convert_from_firestore_format(fields: Dictionary) -> Dictionary:
	var data = {}
	for key in fields:
		var field = fields[key]
		if field.has("mapValue"):
			data[key] = convert_from_firestore_format(field["mapValue"]["fields"])
		elif field.has("stringValue"):
			# Intenta parsear JSON si parece ser un objeto
			var str_value = field["stringValue"]
			if str_value.begins_with("{") and str_value.ends_with("}"):
				var parsed = JSON.parse_string(str_value)
				if parsed != null:
					data[key] = parsed
				else:
					data[key] = str_value
			else:
				data[key] = str_value
		elif field.has("integerValue"):
			data[key] = field["integerValue"].to_int()
		elif field.has("doubleValue"):
			data[key] = float(field["doubleValue"])
		elif field.has("booleanValue"):
			data[key] = field["booleanValue"]
		elif field.has("arrayValue"):
			if field["arrayValue"].has("values"):
				data[key] = convert_array_values(field["arrayValue"]["values"])
			else:
				data[key] = []
	return data

func convert_array_values(firestore_array: Array) -> Array:
	var result = []
	for item in firestore_array:
		if item.has("mapValue"):
			result.append(convert_from_firestore_format(item["mapValue"]["fields"]))
		elif item.has("stringValue"):
			var str_value = item["stringValue"]
			result.append(str_value)
		elif item.has("integerValue"):
			result.append(item["integerValue"].to_int())
		elif item.has("doubleValue"):
			result.append(float(item["doubleValue"]))
		elif item.has("booleanValue"):
			result.append(item["booleanValue"])
		else:
			result.append(item)
	return result


func apply_save_data(save_data: Dictionary) -> bool:
	if save_data.is_empty():
		return false
		
	# Verificar si los datos están anidados
	var actual_data = save_data
	if save_data.has(current_save_name):
		actual_data = save_data[current_save_name]
	
	# Aplicar datos básicos
	Player.player_life = actual_data.get("life", Player.player_life)
	Player.player_gold = actual_data.get("gold", Player.player_gold)
	Player.wave = actual_data.get("days", Player.wave)
	
	# Aplicar datos opcionales
	if actual_data.has("unlocked_towers"):
		Player.unlocked_towers = actual_data.unlocked_towers
	if actual_data.has("difficulty"):
		pass
	if actual_data.has("towers"):
		Player.data.towers = actual_data.towers
		# No instanciamos aquí, lo haremos cuando el mapa esté listo
	
	print("✅ Partida cargada:", current_save_name)
	return true

# Sistema de sincronización
func sync_saved_games() -> bool:
	get_userid()
	if player_id == "guest_user":
		push_error("Usuario no autenticado, no se puede sincronizar")
		return false
		
	print("🔄 Sincronizando partidas...")
	
	var cloud_saves = await load_all_cloud_saves()
	if cloud_saves.is_empty():
		return false
		
	var local_saves = load_local_saves()
	var merged_saves = merge_saves(local_saves, cloud_saves)
	
	return save_merged_saves(merged_saves)

func load_all_cloud_saves() -> Dictionary:
	print("🔍 Iniciando carga de partidas desde la nube...")
	
	var http = create_http_request()
	var request_url = API_URL + "/" + player_id
	print("URL de solicitud: ", request_url)
	
	var error = http.request(request_url, header, HTTPClient.METHOD_GET)
	print("Resultado de la solicitud HTTP (0=OK): ", error)
	
	if error != OK:
		push_error("❌ Error en petición HTTP: " + str(error))
		return {}

	print("⌛ Esperando respuesta de la nube...")
	var result = await http.request_completed
	print("✅ Respuesta recibida")
	
	# Desempaquetar el resultado
	var response_code = result[1]
	var body = result[3].get_string_from_utf8() if result[3] else ""
	
	if response_code != 200:
		push_error("❌ Error en la respuesta HTTP: Código " + str(response_code))
		return {}

	print("🔍 Parseando JSON de la respuesta...")
	var json = JSON.new()
	var parse_error = json.parse(body)
	
	if parse_error != OK:
		push_error("❌ Error parseando JSON: ", parse_error)
		push_error("JSON problemático: ", json.get_error_message())
		return {}

	var response_data = json.get_data()
	print("Tipo de datos parseados: ", typeof(response_data))
	
	if typeof(response_data) != TYPE_DICTIONARY:
		push_error("❌ La respuesta no es un diccionario")
		return {}

	# Debug avanzado de la estructura de datos
	print("🔍 Analizando estructura de datos recibida...")
	if response_data.has("error"):
		push_error("❌ Error en la respuesta de Firestore: ", response_data.error)
		return {}
	
	if not response_data.has("fields"):
		
		# Alternativa para documentos individuales
		if response_data.has("name"):
			print("📄 Se recibió un documento individual")
			var converted_data1 = convert_from_firestore_format(response_data.get("fields", {}))
			return converted_data1
		else:
			push_error("❌ Formato de respuesta inesperado")
			return {}

	print("✅ Estructura de datos válida encontrada")
	var converted_data = convert_from_firestore_format(response_data["fields"])
	
	return converted_data


func merge_saves(local: Dictionary, cloud: Dictionary) -> Dictionary:
	var merged = local.duplicate()
	
	# Prioridad a los datos de la nube
	for save_name in cloud:
		var cloud_save = cloud[save_name]
		var local_save = local.get(save_name, {})
		
		# Conservar el más reciente
		if local_save.get(TIMESTAMP_KEY, 0) < cloud_save.get(TIMESTAMP_KEY, 0):
			merged[save_name] = cloud_save
	
	return merged

func save_merged_saves(saves: Dictionary) -> bool:
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Error guardando partidas sincronizadas")
		return false
		
	file.store_string(JSON.stringify(saves, "\t"))
	file.close()
	print("✅ Sincronización completada")
	return true

# Sistema de eliminación
func delete_game_named(save_name: String) -> bool:
	get_userid()
	
	# Eliminar localmente
	var local_success = delete_local_save(save_name)
	
	# Eliminar en la nube si está logueado
	var cloud_success = true
	if player_id != "guest_user":
		cloud_success = await delete_cloud_save(save_name)
	
	return local_success and cloud_success

func delete_local_save(save_name: String) -> bool:
	var all_saves = load_local_saves()
	if not all_saves.has(save_name):
		return true
		
	all_saves.erase(save_name)
	
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Error eliminando partida local")
		return false
		
	file.store_string(JSON.stringify(all_saves, "\t"))
	file.close()
	print("🗑️ Partida eliminada localmente:", save_name)
	return true

func delete_cloud_save(save_name: String) -> bool:
	var http = create_http_request()

	var request_url = API_URL + "/" + player_id + "?updateMask.fieldPaths=" + save_name

	var body_dict = {
		"fields": { save_name: { "nullValue": null } }
	}
	var body = JSON.stringify(body_dict)

	var error = http.request(request_url, header, HTTPClient.METHOD_PATCH, body)

	if error != OK:
		push_error("Error en petición HTTP: " + str(error))
		return false

	var result = await http.request_completed
	var response = process_http_response(result, "eliminar")

	if response.success:
		print("🗑️ Partida eliminada en la nube:", save_name)
	else:
		push_error("Error eliminando partida en la nube")

	return response.success


# Utilidades
func create_http_request() -> HTTPRequest:
	var request = HTTPRequest.new()
	add_child(request)
	return request

func process_http_response(result: Array, action: String) -> Dictionary:
	var response_code = result[1]
	var body = result[3].get_string_from_utf8()
	
	print("Respuesta HTTP (%s) - Código: %d" % [action, response_code])
	
	if response_code != 200:
		push_error("Error en %s. Código: %d - Respuesta: %s" % [action, response_code, body])
		return {"success": false, "body": body}
	
	return {"success": true, "body": body}
	
