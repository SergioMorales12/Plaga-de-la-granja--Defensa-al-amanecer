extends Control


var mapSelectContainer : Node2D


func _ready():
	load_save_games()


func load_save_games():
	var json = JSON.new()
	var file = FileAccess.open(Global.FILE_PATH, FileAccess.READ)
	
	if file:
		var file_text = file.get_as_text()
		file.close()
		
		var error = json.parse(file_text)
		if error == OK:
			var data_received = json.data
			if typeof(data_received) == TYPE_ARRAY:
				# Crear un diccionario de partidas por ID
				var partidas_por_id = {}
				var menu = $Buttons/VBoxContainer/MenuButton.get_popup()

				# Limpiar el menú antes de agregar nuevos ítems
				menu.clear()
				for partida in data_received:
					partidas_por_id[int(partida["_id"])] = partida
					menu.add_item(String(partida["name"]))


				menu.id_pressed.connect(_on_menu_button_about_to_popup)
				#print(partidas_por_id)
				return partidas_por_id

			else:
				print("Unexpected Data")
				return {}
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", file_text)
			return {}
	else:
		print("Error opening file")
		return {}



func _on_save_game_selected(id):
	var menu = $Buttons/VBoxContainer/MenuButton/PopupMenu
	var save_game_path = menu.get_item_metadata(id)
	print("Cargar partida desde: " + save_game_path)
	# Aquí puedes añadir la lógica para cargar la partida seleccionada

func _on_exit_button_pressed():
	get_tree().quit()

func _on_start_button_pressed():
	Global.change_scene("res://scenes/mapa.tscn")


func _on_continue_button_pressed():
	pass  # Reemplazar con la lógica para continuar la partida

func _on_menu_button_about_to_popup():
	pass  # Reemplazar con la lógica necesaria antes de mostrar el menú
