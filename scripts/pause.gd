extends CanvasLayer

var game_paused: bool = false

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # Para recibir input siempre
	
	# Configurar música para que no se pausa con el juego
	if has_node("AudioStreamPlayer"):
		$AudioStreamPlayer.process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(_delta: float):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func toggle_pause():
	game_paused = !game_paused
	get_tree().paused = game_paused
	visible = game_paused
	
	# Mantener la música sonando independientemente del pause
	if has_node("AudioStreamPlayer"):
		if not $AudioStreamPlayer.playing:
			$AudioStreamPlayer.play()

func _on_replay_pressed() -> void:
	toggle_pause()

func _on_save_pressed() -> void:
	if Global and Global.current_save_name != "":
		# Feedback visual al guardar
		$TextureRect/buttons/Save/Label.text = "Guardando..."
		$TextureRect/buttons/Save.disabled = true
		
		# Esperar un frame para que se actualice la UI
		await get_tree().process_frame
		
		# Llamar a la función de guardado
		Global.save_game_named(Global.current_save_name)
		
		# Restaurar el botón
		$TextureRect/buttons/Save/Label.text = "Guardar"
		$TextureRect/buttons/Save.disabled = false
		
	else:
		push_error("No se puede guardar: nombre de partida no válido")

func _on_restart_pressed() -> void:
	toggle_pause()
	Global.restart_map()

func _on_main_menu_pressed() -> void:
	toggle_pause()
	Global.change_scene("res://scenes/main_menu.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
