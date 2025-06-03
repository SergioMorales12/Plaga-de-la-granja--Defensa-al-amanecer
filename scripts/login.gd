extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  


func _on_start_pressed() -> void:
	if login_correct():
		Global.change_scene("res://scenes/main_menu.tscn")
	else:
		print("ERROR EN EL LOGIN")

func _on_register_pressed() -> void:
	Global.change_scene("res://scenes/register.tscn")


func _on_guest_pressed() -> void:
	Global.change_scene("res://scenes/main_menu.tscn")


func _on_username_text_set():
	var texto = $VBoxContainer/username.text
	if texto != "":
		return true
	return false


func _on_pass_text_set():
	var texto = $VBoxContainer/pass.text
	if texto != "":
		return true
	return false

func _on_exit_button_pressed():
	get_tree().quit()

func login_correct():
	if _on_username_text_set() and _on_pass_text_set():
		return true
	else:
		return false
