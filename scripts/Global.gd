extends Node

var FILE_PATH := "res://Games/save_games.json"
var map_select_container: Node2D
var current_scene_path: String = ""
var current_save_name: String



func change_scene(new_scene_path: String) -> void:
	current_scene_path = new_scene_path
	get_tree().change_scene_to_file(new_scene_path)
	await get_tree().process_frame  
	print(current_scene_path)


func restart_map() -> void:
	if map_select_container != null:
		get_tree().change_scene_to_file(map_select_container.get_path())
		print("Reiniciando escena:", current_scene_path)
	else:
		push_error("No se ha cargado ninguna escena para reiniciar.")

func restart_scene() -> void:
	if current_scene_path != "":
		get_tree().change_scene_to_file(current_scene_path)
		print("Reiniciando escena:", current_scene_path)
	else:
		push_error("No se ha cargado ninguna escena para reiniciar.")

func change_map(map_path: String) -> void:
	if map_select_container:
		map_select_container.queue_free()
		map_select_container = load(map_path).instantiate()
	get_tree().current_scene.add_child(map_select_container)
	print("Mapa cambiado a:", map_path)

func save_game_named(name: String):
	current_save_name = name
	var towers_data = []
	for tower in $/root/Mapa/towers.get_children():
		if tower.has_method("get_save_data"):
			towers_data.append(tower.get_save_data())
	
	var save_data = {
		"towers": towers_data,
		"player_gold": Player.player_gold,
		"player_life": Player.player_life,
		"unlocked_towers": Player.unlocked_towers,
		"dificulty":Player.dificulty,
		"current_day": int(Player.wave),
		"timestamp": Time.get_datetime_string_from_system()
	}

	var all_saves = {}
	if FileAccess.file_exists(FILE_PATH):
		var file = FileAccess.open(FILE_PATH, FileAccess.READ)
		var json_text = file.get_as_text()
		file.close()
		all_saves = JSON.parse_string(json_text) if json_text != "" else {}

	all_saves[name] = save_data

	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(all_saves, "\t"))
	file.close()

func load_game_named(name: String) -> bool:
	# Verificación inicial del archivo
	if not FileAccess.file_exists(FILE_PATH):
		push_error("Archivo de guardado no existe en: " + FILE_PATH)
		return false
	
	# Leer el archivo
	var file = FileAccess.open(FILE_PATH, FileAccess.READ)
	if not file:
		push_error("Error al abrir archivo de guardado")
		return false
	
	var json_text = file.get_as_text()
	file.close()
	
	# Parsear JSON
	var json = JSON.new()
	var parse_error = json.parse(json_text)
	if parse_error != OK:
		push_error("Error al parsear JSON: " + json.get_error_message())
		return false
	
	var all_saves = json.get_data()
	if not all_saves is Dictionary:
		push_error("Datos de guardado no son un diccionario válido")
		return false
	
	# Verificar partida existente
	if name not in all_saves:
		push_error("No existe la partida: " + name)
		return false
	
	var save_data = all_saves[name]
	
	# Validar datos esenciales
	if not save_data.has("player_gold") or not save_data.has("player_life") or not save_data.has("current_day"):
		push_error("Datos de guardado incompletos")
		return false
	
	# Cargar datos del jugador
	Player.player_gold = float(save_data["player_gold"])
	Player.player_life = float(save_data["player_life"])
	Player.wave = int(save_data["current_day"])
	Player.dificulty = float(save_data.get("dificulty", 1))
	Player.unlocked_towers = save_data.get("unlocked_towers", []).duplicate()
	
	# Cambiar a la escena guardada si es diferente
	var target_scene = save_data.get("scene_path", "res://scenes/mapa.tscn")
	if target_scene != current_scene_path:
		change_scene(target_scene)
		await get_tree().process_frame

	await get_tree().process_frame
	# Cargar torres si la escena está lista
	var mapa := get_tree().current_scene
	print("Nodo raíz actual:", mapa)
	if mapa:
		var towers_node = mapa.get_node_or_null("towers")
		print("Nodo towers:", towers_node)
		if towers_node:
			# Limpiar torres existentes
			for child in towers_node.get_children():
				child.queue_free()
			
			# Cargar torres guardadas
			for tower_data in save_data.get("towers", []):
				if not tower_data.has("scene_path"):
					continue
					
				var scene = load(tower_data["scene_path"])
				if scene:
					var tower = scene.instantiate()
					if tower.has_method("load_save_data"):
						tower.load_save_data(tower_data)
					towers_node.add_child(tower)
	
	print("Partida cargada correctamente: ", name)
	return true
