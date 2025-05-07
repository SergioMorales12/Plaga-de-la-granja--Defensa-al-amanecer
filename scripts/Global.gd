extends Node

var FILE_PATH = "res://Games/save_games.json"

var mapSelectContainer : Node2D

func change_scene(new_scene_path: String):

	get_tree().change_scene_to_file(new_scene_path)
	print_stack() 


		
