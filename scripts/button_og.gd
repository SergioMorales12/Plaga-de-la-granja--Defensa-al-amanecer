extends Control

@export var label: String = ""  
@export var path: String = ""  

func _ready() -> void:
	$Button/Label.text = label  

func _on_button_pressed() -> void:
	if path == "":
		print(path)
		return
	elif path == "RESTART":
		Global.restart_map()
		Input.action_press("pause")
		return
	elif path == "PAUSE":
		Input.action_press("pause")
		return
	Global.change_scene(path) 
