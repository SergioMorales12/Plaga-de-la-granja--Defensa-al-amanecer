extends CanvasLayer

var game_paused: bool = false

func _ready():
	visible = false
	# Ensure this CanvasLayer processes input even when the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# We should ideally prevent the specific audio streams from pausing with the game
	# by setting their 'process_mode' to ALWAYS.
	# It's better to do this on the AudioStreamPlayer nodes themselves in the editor
	# or when they are created, rather than in this pause menu script,
	# as this script might not have direct access to all audio players.
	# However, if you have a specific AudioStreamPlayer child named "AudioStreamPlayer"
	# that you want to control here, the original line is correct.
	# For now, I'll keep your original check, but note the above.
	if has_node("Musica"):
		$Musica.process_mode = Node.PROCESS_MODE_ALWAYS
	# Initialize the volume slider
	# Ensure the slider node is correctly named "Volumen" and is a child of this CanvasLayer.
	if has_node("TextureRect/Volumen"):
		var master_bus_index = AudioServer.get_bus_index("Master")
		if master_bus_index != -1: # Check if Master bus exists
			var current_volume_db = AudioServer.get_bus_volume_db(master_bus_index)
			# Convert from decibels (-80 to 0) to slider percentage (0 to 100)
			# `inverse_lerp` is great for this!
			$TextureRect/Volumen.value = inverse_lerp(-80.0, 0.0, current_volume_db) * 100.0
		else:
			push_error("Audio bus 'Master' not found. Volume initialization failed.")

func _physics_process(_delta: float):
	# Using `_unhandled_input` is generally better for pause menus
	# to avoid consuming input that other game elements might need.
	# But for a simple pause, `_physics_process` is fine.
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func toggle_pause():
	game_paused = !game_paused
	get_tree().paused = game_paused
	visible = game_paused
	
	if has_node("Musica"):
		if game_paused:
			$Musica.play()
		else:
			$Musica.stop()

func _on_replay_pressed() -> void:
	toggle_pause()

func _on_save_pressed() -> void:
	# Assuming 'Global' is an AutoLoad singleton.
	if Global and Global.current_save_name != "":
		$TextureRect/buttons/Save/Label.text = "Saving..." # Changed to English for consistency or adjust
		$TextureRect/buttons/Save.disabled = true
		
		# Give the UI a frame to update before saving
		await get_tree().process_frame
		
		Global.save_game_named(Global.current_save_name)
		
		$TextureRect/buttons/Save/Label.text = "Saved" # Changed to English for consistency or adjust
		$TextureRect/buttons/Save.disabled = false
	else:
		push_error("Cannot save: Invalid save name or Global script not loaded.")

func _on_restart_pressed() -> void:
	toggle_pause()
	Global.restart_map()

func _on_main_menu_pressed() -> void:
	toggle_pause()
	Global.change_scene("res://scenes/main_menu.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_auto_savev_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$TextureRect/buttons/AutoSave/Label.text = "Auto Save On"
		Player.auto_save = true
	else:
		Player.auto_save = false

func _on_volumen_value_changed(value: float) -> void:
	var min_db = -30.0  # Volumen mínimo audible
	var linear_value = max(value / 100.0, 0.001)  # Evitar log(0)
	var volume_db = lerp(min_db, 0.0, log(linear_value * 9 + 1) / log(10))  # Logarítmico

	var master_bus_index = AudioServer.get_bus_index("Master")
	if master_bus_index != -1:
		AudioServer.set_bus_volume_db(master_bus_index, volume_db)
		if Global:
			Global.volume_db = volume_db
		# Opcional: Actualiza un label
		$TextureRect/VolumenLabel.text = str(round(value)) + "%"
	else:
		push_error("Audio bus 'Master' not found. Volume adjustment failed.")
