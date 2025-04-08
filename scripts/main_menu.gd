extends Control


var mapSelectContainer : Node2D

func _ready():
	# Cargar las partidas guardadas
	var save_games = load_save_games()
	# Ordenar las partidas por fecha (suponiendo que cada partida tiene un campo 'date')
	save_games.sort_custom(func(a, b): return a.date > b.date)

	# Crear botones dinámicamente
	var menu = $Buttons/VBoxContainer/MenuButton/PopupMenu
	menu.clear()  # Limpiar cualquier ítem previo

	for i in range(save_games.size()):
		menu.add_item("Partida " + str(i + 1) + ": " + save_games[i].name)
		menu.set_item_metadata(i, save_games[i].path)  # Guardar la ruta del archivo como metadata

	# Conectar la señal para manejar la selección de partidas
	#menu.connect("id_pressed", self, "_on_save_game_selected")

func load_save_games():
	var file = FileAccess.open("res://save_games.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var result = json.parse(json_string)
		if result.error == OK:
			var data = result.result
			print(data)
		else:
			print("Error parsing JSON")
		
		var save_games_result = json.parse(json_string)
		if save_games_result.error == OK:
			var save_games = save_games_result.result
			return save_games
		else:
			print("Error parsing save games JSON")
			return null
	else:
		print("Error opening file")
		return null


func _on_save_game_selected(id):
	var menu = $Buttons/VBoxContainer/MenuButton/PopupMenu
	var save_game_path = menu.get_item_metadata(id)
	print("Cargar partida desde: " + save_game_path)
	# Aquí puedes añadir la lógica para cargar la partida seleccionada

func _on_exit_button_pressed():
	get_tree().quit()

func _on_start_button_pressed():
	if not mapSelectContainer:
		var mscScene = preload("res://scenes/mapa.tscn")
		var msc = mscScene.instantiate()
		mapSelectContainer = msc
		add_child(msc)

func _on_continue_button_pressed():
	pass  # Reemplazar con la lógica para continuar la partida

func _on_menu_button_about_to_popup():
	pass  # Reemplazar con la lógica necesaria antes de mostrar el menú
