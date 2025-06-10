extends Control

func _ready() -> void:
	Firebase.Auth.login_succeeded.connect(on_loging_succeded)
	Firebase.Auth.signup_succeeded.connect(on_register_succeded)
	Firebase.Auth.login_failed.connect(on_loging_failed)
	Firebase.Auth.signup_failed.connect(on_register_failed)
	if Firebase.Auth.check_auth_file():
		%StateLabel.text = "Logged in"
		Global.change_scene("res://scenes/main_menu.tscn")
	process_mode = Node.PROCESS_MODE_ALWAYS  


func _on_start_pressed() -> void:
	var email = %email.text
	var password = %pass.text
	Firebase.Auth.login_with_email_and_password(email,password)
	%StateLabel.text = "Logging in"


func _on_register_pressed() -> void:
	var email = %email.text
	var password = %pass.text
	Firebase.Auth.signup_with_email_and_password(email,password)
	%StateLabel.text = "Singing up"


func _on_guest_pressed() -> void:
	Global.change_scene("res://scenes/main_menu.tscn")

func on_loging_succeded(auth):
	print(auth)
	%StateLabel.text = "Login success!"
	Firebase.Auth.save_auth(auth)
	Global.change_scene("res://scenes/main_menu.tscn")


func on_register_succeded(auth):
	print(auth)
	%StateLabel.text = "Register success!"
	Firebase.Auth.save_auth(auth)
	Global.change_scene("res://scenes/main_menu.tscn")


func on_loging_failed(error_code,message):
	print(error_code)
	print(message)
	%StateLabel.text = "Login failed. Error: %s" % message


func on_register_failed(error_code,message):
	print(error_code)
	print(message)
	%StateLabel.text = "Register failed. Error: %s" % message


func _on_exit_button_pressed():
	get_tree().quit()


func _on_google_pressed() -> void:
	var port = 8060
	var provider : AuthProvider = Firebase.Auth.get_GoogleProvider()
	Firebase.Auth.get_auth_localhost(provider,port)
