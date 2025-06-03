extends Node

var FILE_PATH := "res://Games/save_games.json"
var map_select_container: Node2D
var current_scene_path: String = ""
var current_save_name: String

func change_scene(new_scene_path: String) -> void:
	current_scene_path = new_scene_path
	get_tree().change_scene_to_file(new_scene_path)
	print("Cambiando a la escena:", new_scene_path)

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
	var towers_data = []
	for tower in $/root/Mapa/towers.get_children():
		if tower.has_method("get_save_data"):
			towers_data.append(tower.get_save_data())

	var save_data = {
		"towers": towers_data,
		"player_gold": Player.player_gold,
		"player_life": Player.player_life,
		"unlocked_towers": Player.unlocked_towers,
		"current_day": Player.wave,
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

func load_game_named(name: String):
	if not FileAccess.file_exists(FILE_PATH):
		print("Archivo de guardado no existe.")
		return

	var file = FileAccess.open(FILE_PATH, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()

	var all_saves = JSON.parse_string(json_text)
	if not all_saves or name not in all_saves:
		print("No existe la partida: " + name)
		return

	var save_data = all_saves[name]
	Player.player_gold = save_data["player_gold"]
	Player.player_life = save_data["player_life"]
	Player.unlocked_towers = save_data["unlocked_towers"]
	Player.wave = save_data["current_day"]

	# Si la escena ya está cargada, puedes restaurar torres:
	if has_node("/root/Mapa/towers"):
		for child in $/root/Mapa/towers.get_children():
			child.queue_free()

		for tower_data in save_data["towers"]:
			var scene = load(tower_data["scene_path"])
			if scene:
				var tower = scene.instantiate()
				tower.position = tower_data["position"]
				tower.damage = tower_data["damage"]
				tower.bulletSpeed = tower_data["bulletSpeed"]
				tower.attack_interval = tower_data["attack_interval"]
				tower.upgrade_levels = tower_data["upgrade_levels"]
				$/root/Mapa/towers.add_child(tower)
