extends Panel

@export var tower : PackedScene  
var tempTower  
var canPlace = false  
var price
var canBuy = false  

func _process(_delta: float) -> void:
		check_gold()

func _ready() -> void:
	if tower:
		var preview = tower.instantiate()
		price = preview.price
		$Price.text = "$" + str(price)
		
		# Verificar si el jugador tiene suficiente oro
		check_gold()
		
		# Desactiva lógica para que sea solo una vista previa visual
		if preview.get("can_attack") != null:
			preview.set("can_attack", false)
		if preview.get("is_preview") != null:
			preview.set("is_preview", true)


		if preview.has_node("Area2D"):
			preview.get_node("Area2D").process_mode = Node.PROCESS_MODE_DISABLED
		if preview.has_node("Area"):
			preview.get_node("Area").hide()
		if preview.has_node("colision"):
			preview.get_node("colision").monitoring = false
		if preview.has_node("AnimatedSprite2D"):
			preview.get_node("AnimatedSprite2D").stop() 

		# Escalado desde variable 'escala'
		var escala = preview.get("escala") 
		preview.scale = Vector2.ONE * escala

		# Posición centrada
		preview.position = size / 2

		add_child(preview)

func check_gold():
	# Verifica si el jugador tiene suficiente oro
	if Player.player_gold >= price:
		canBuy = true
		modulate = Color(1, 1, 1)
	else:
		canBuy = false
		modulate = Color(0.5, 0.5, 0.5) 

func _on_gui_input(event: InputEvent) -> void:
	check_gold()
	if not canBuy:
		return
		
	if event is InputEventMouseButton and event.button_mask == 1:
		tempTower = tower.instantiate() 
		add_child(tempTower) 
		
		tempTower.set_physics_process(true)  
		tempTower.get_node("Area").show()
		tempTower.get_node("Area2D").hide()  
		tempTower.get_node("Area2D").process_mode = Node.PROCESS_MODE_DISABLED

	elif event is InputEventMouseMotion and event.button_mask == 1:  
		if tempTower:
			tempTower.global_position = event.global_position  
			
			if tempTower.get_node("colision").get_overlapping_bodies().size() <1 and isTower(tempTower):
				canPlace = true
			else:
				canPlace = false
			
			if event.global_position.x >= 1792:
				tempTower.get_node("Area").modulate = Color(1, 0, 0)
			else:
				tempTower.get_node("Area").modulate = Color(1, 1, 1) if canPlace else Color(1, 0, 0)  

	elif event is InputEventMouseButton and event.button_mask == 0:  
		if tempTower:
			if event.global_position.x >= 1784:
				canPlace = false

			tempTower.get_node("Area").hide() # Oculta el área de la torreta
			if canPlace:
				var path = get_tree().get_root().get_node("Mapa/towers") # Obtiene el nodo donde se colocará la torreta
				remove_child(tempTower) # Elimina la torreta del panel
				path.add_child(tempTower) # Añade la torreta al nodo `towers`
				tempTower.global_position = event.global_position # Actualiza la posición de la torreta
				tempTower.set_physics_process(true) # Reactiva el procesamiento de física
				tempTower.get_node("Area2D").process_mode = Node.PROCESS_MODE_INHERIT
				
				# Restar el oro al jugador
				Player.player_gold -= price
				Player.update_ui()
				# Actualizar la UI del oro 
				if Player.has_method("update_gold_ui"):
					Player.update_gold_ui()
				# Verificar de nuevo el oro disponible
				check_gold()
			else:
				tempTower.queue_free() # Elimina la torreta si no se puede colocar
			tempTower = null # Resetea la variable de la torreta temporal

func isTower(towers: Node):
	var overlapping_areas = towers.get_node("colision").get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group("towers"):
			return false
	return true
