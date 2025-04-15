extends Panel

@export var tower = preload("res://scenes/towers/espanta_pajaros.tscn") # Carga la escena de la torreta
var tempTower # Variable para almacenar la torreta temporal
var canPlace = true # Variable para verificar si se puede colocar la torreta

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_mask == 1: # Al hacer clic con el botón izquierdo del ratón
		tempTower = tower.instantiate() # Instancia la torreta
		add_child(tempTower) # Añade la torreta como hijo del panel
		tempTower.process_mode = Node.PROCESS_MODE_DISABLED # Desactiva el procesamiento de la torreta
		tempTower.get_node("Area").show() # Muestra el área de la torreta
		
	elif event is InputEventMouseMotion and event.button_mask == 1: # Al mover el ratón con el botón izquierdo presionado
		if tempTower:
			tempTower.global_position = event.global_position # Actualiza la posición de la torreta
			canPlace = not is_colliding(tempTower.global_position) # Verifica si hay colisión en la posición actual
			tempTower.get_node("Area").modulate = Color(1, 1, 1) if canPlace else Color(1, 0, 0) # Cambia el color del área según si hay colisión
			
	elif event is InputEventMouseButton and event.button_mask == 0: # Al soltar el botón izquierdo del ratón
		if tempTower:
			tempTower.get_node("Area").hide() # Oculta el área de la torreta
			if canPlace:
				var path = get_tree().get_root().get_node("Mapa/towers") # Obtiene el nodo donde se colocará la torreta
				remove_child(tempTower) # Elimina la torreta del panel
				path.add_child(tempTower) # Añade la torreta al nodo `towers`
				tempTower.global_position = event.global_position # Actualiza la posición de la torreta
				tempTower.process_mode = Node.PROCESS_MODE_INHERIT # Reactiva el procesamiento de la torreta
			else:
				tempTower.queue_free() # Elimina la torreta si no se puede colocar
			tempTower = null # Resetea la variable de la torreta temporal
func is_colliding(position: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state # Obtiene el estado del espacio 2D
	var query = PhysicsPointQueryParameters2D.new() # Crea un nuevo objeto de parámetros de consulta de punto
	query.position = position # Establece la posición de la consulta
	var result = space_state.intersect_point(query) # Realiza la consulta de intersección
	return result.size() > 0 # Devuelve verdadero si hay colisión
