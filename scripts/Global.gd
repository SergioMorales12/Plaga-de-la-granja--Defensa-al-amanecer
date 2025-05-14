extends Node

var FILE_PATH := "res://Games/save_games.json"

var map_select_container: Node2D

var current_scene_path: String = ""

func change_scene(new_scene_path: String) -> void:
	current_scene_path = new_scene_path
	get_tree().change_scene_to_file(new_scene_path)
	print("Cambiando a la escena:", new_scene_path)
	print_stack()

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

func save_game(data: Dictionary) -> void:
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("Juego guardado en:", FILE_PATH)

func load_game() -> Dictionary:
	if FileAccess.file_exists(FILE_PATH):
		var file = FileAccess.open(FILE_PATH, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			return data
	return {}
