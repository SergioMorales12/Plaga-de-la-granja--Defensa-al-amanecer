extends CanvasLayer


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$AudioStreamPlayer.play()

func _on_quit_button_pressed():
	get_tree().paused = false
	Global.change_scene("res://scenes/main_menu.tscn")
