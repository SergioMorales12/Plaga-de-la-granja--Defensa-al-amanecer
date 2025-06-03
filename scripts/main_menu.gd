extends Control

func _ready():
	load_save_games()
	process_mode = Node.PROCESS_MODE_ALWAYS

	var menu = $Buttons/VBoxContainer/MenuButton.get_popup()
	if not menu.is_connected("id_pressed", self, "_on_menu_button_id_pressed"):
		menu.connect("id_pressed", self, "_on_menu_button_id_pressed")

func load_save_games():
	var menu = $Buttons/VBoxContainer/MenuButton.get_popup()
	menu.clear()

	if not FileAccess.file_exists(Global.FILE_PATH):
		return

	var file = FileAccess.open(Global.FILE_PATH, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()

	var saves = JSON.parse_string(json_text)
	if saves is Dictionary:
		for name in saves.keys():
			menu.add_item(name)
			menu.set_item_metadata(menu.get_item_count() - 1, name)

func _on_exit_button_pressed():
	get_tree().quit()

func _on_start_button_pressed():
	var save_name = "partida_" + str(randi() % 10000)
	Global.current_save_name = save_name
	Global.change_scene("res://scenes/mapa.tscn")

func _on_menu_button_id_pressed(id):
	var menu = $Buttons/VBoxContainer/MenuButton.get_popup()
	var save_name = menu.get_item_metadata(id)

	if save_name != null:
		Global.load_game_named(save_name)
		Global.current_save_name = save_name
		Global.change_scene("res://scenes/mapa.tscn")
