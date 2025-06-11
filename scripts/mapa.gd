extends Node

# Diálogos especiales por oleada exacta
var special_wave_dialogs := {
	1: "intro_tutorial",
	5: "primer_enjambre",
	10: "primer_boss",
	33: "como_33",
	40: "lore_planta"
}

# Referencia al contenedor de torres
var towers_container: Node2D 

func _ready():
	towers_container = get_tree().get_root().get_node("Mapa/towers")
	
	# Cargar torres si existen en los datos del jugador
	if Player.data.has("towers") :
		load_saved_towers(Player.data.towers)

func load_saved_towers(towers_data: Array) -> void:
	print("Cargando torres guardadas...")
	# Limpiar torres existentes (opcional, depende de tu lógica de juego)
	for child in towers_container.get_children():
		child.queue_free()
	
	# Instanciar cada torre guardada
	for tower_data in towers_data:
		if typeof(tower_data) != TYPE_DICTIONARY:
			if parse_data_string(tower_data) == {}:
				push_error("Datos de torre inválidos: ", tower_data)
				continue
			tower_data = parse_data_string(tower_data)
		_instantiate_tower(tower_data)

func parse_data_string(data_string: String) -> Dictionary:
	var cleaned_string = ""  # Declaración fuera del if para que sea accesible

	# Elimina 'data(' al principio y ')' al final de forma manual
	if data_string.begins_with("data("):
		cleaned_string = data_string.substr(5, data_string.length() - 6)
	else:
		cleaned_string = data_string

	# Reemplaza paréntesis por corchetes para que sea JSON válido
	cleaned_string = cleaned_string.replace('(', '[').replace(')', ']')
	
	# Parsear JSON
	var json = JSON.new()
	var result = json.parse(cleaned_string)
	if result != OK:
		push_error("Error parsing JSON: %s" % json.get_error_message())
		return {}  # Retorna diccionario vacío en caso de error

	return json.get_data()

func _instantiate_tower(tower_data: Dictionary) -> void:
	var scene_path = tower_data["scene_path"]
	
	# Cargar la escena de la torre
	if not ResourceLoader.exists(scene_path):
		push_error("No existe la escena de torre: ", scene_path)
		return
		
	var tower_scene = load(scene_path)
	if not tower_scene:
		push_error("Error cargando la escena: ", scene_path)
		return
	
	# Instanciar la torre
	var tower_instance = tower_scene.instantiate()
	
	# Establecer posición
	var position = _parse_position(tower_data["position"])
	tower_instance.global_position = position
	
	# Añadir al contenedor
	towers_container.add_child(tower_instance)
	
	# Configurar propiedades adicionales
	if tower_data.has("level"):
		tower_instance.level = tower_data["level"]
	if tower_data.has("upgrades"):
		tower_instance.upgrades = tower_data["upgrades"]
	if tower_data.has("lore_progress"):
		tower_data["lore1_unlocked"] = Dialogic.VAR.get_variable("Espanta.Lore1")
		tower_data["lore2_unlocked"] =  Dialogic.VAR.get_variable("Espanta.Lore2")
		tower_data["lore3_unlocked"] = Dialogic.VAR.get_variable("Espanta.Lore3")
		tower_data["lore4_unlocked"] = Dialogic.VAR.get_variable("Espanta.Lore4")
		
	print("Torre instanciada en ", position)

func _parse_position(pos_data) -> Vector2:
	# Convierte la posición a Vector2, manejando diferentes formatos
	if typeof(pos_data) == TYPE_VECTOR2:
		return pos_data
	elif typeof(pos_data) == TYPE_STRING:
		# Formato "(x, y)"
		var cleaned = pos_data.replace("(", "").replace(")", "").replace(" ", "")
		var parts = cleaned.split(",")
		if parts.size() == 2:
			return Vector2(float(parts[0]), float(parts[1]))
	elif typeof(pos_data) == TYPE_ARRAY and pos_data.size() == 2:
		return Vector2(pos_data[0], pos_data[1])
	
	push_error("Formato de posición inválido: ", pos_data)
	return Vector2.ZERO

func play_wave_dialog(current_wave: int) -> void:
	if special_wave_dialogs.has(current_wave):
		# Mostrar diálogo especial
		Dialogic.start(special_wave_dialogs[current_wave])
	else:
		# Mostrar diálogo aleatorio (30% de probabilidad)
		if randi_range(0, 100) < 0:  # Nota: 0% de probabilidad actualmente
			Dialogic.start("random_wave_%d" % randi_range(1, 19))
