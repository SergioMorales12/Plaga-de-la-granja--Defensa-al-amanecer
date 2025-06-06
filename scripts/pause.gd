extends CanvasLayer

var game_paused: bool = false
var game_name = Global.current_save_name

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
	if has_node("Musica"):
		$Musica.playing = !game_paused
	for child in get_children():
		print("   - ", child.name, " (", child.get_class(), ")")


func _on_replay_pressed() -> void:
	toggle_pause()
	

func _on_save_pressed() -> void:
	if Global :
		Global.save_game_named(game_name)


func _on_restart_pressed() -> void:
	toggle_pause()
	Global.restart_map()


func _on_main_menu_pressed() -> void:
	toggle_pause()
	Global.change_scene("res://scenes/main_menu.tscn")
