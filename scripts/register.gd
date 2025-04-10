extends Control


func _on_start_pressed() -> void:
	if register_cofirm():	
		Global.change_scene("res://scenes/main_menu.tscn")



func _on_login_pressed() -> void:
	Global.change_scene("res://scenes/login.tscn")



func _on_guest_pressed() -> void:
	Global.change_scene("res://scenes/main_menu.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
	

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


func _on_confirmpass_text_set():
	var texto = $VBoxContainer/confirmpass.text
	if texto != "":
		return true
	return false

func register_cofirm():
	if _on_username_text_set() and _on_pass_text_set() and ($VBoxContainer/confirmpass.text == $VBoxContainer/pass.text ):
		return true
	else:
		return false
