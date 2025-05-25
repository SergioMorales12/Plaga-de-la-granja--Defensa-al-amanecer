extends CanvasLayer

var game_paused: bool = false

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # Para recibir input siempre

func _physics_process(_delta: float):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func toggle_pause():
	game_paused = !game_paused
	get_tree().paused = game_paused
	visible = game_paused  # Esto controla la visibilidad del menú completo
	
	# Opcional: Enfocar el primer botón cuando se muestra
	if game_paused and has_node("Buttons/Settings"):
		$Buttons/Settings.grab_focus()

# Cambia todas estas funciones para usar toggle_pause()
func _on_login_pressed() -> void:
	Global.restart_scene()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_replay_pressed() -> void:
	toggle_pause()
	
func _on_settings_pressed() -> void:
	toggle_pause()  

func _on_save_pressed() -> void:
	if Player and Player.has("info"):
		Global.save_game(Player.info)


func _on_restart_pressed() -> void:
	Global.restart_map()


func _on_main_menu_pressed() -> void:
	Global.change_scene("res://scenes/main_menu.tscn")
