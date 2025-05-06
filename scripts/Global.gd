extends Node

var FILE_PATH = "res://Games/save_games.json"

var mapSelectContainer : Node2D

func change_scene(new_scene_path: String):
	var nueva_escena = load(new_scene_path).instantiate()
	var escena_actual = get_tree().current_scene
	
	if escena_actual:
		escena_actual.queue_free()
		
	get_tree().root.add_child(nueva_escena)
	get_tree().current_scene = nueva_escena
