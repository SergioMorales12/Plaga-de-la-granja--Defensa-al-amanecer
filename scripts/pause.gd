extends CanvasLayer

func _physics_process(delta: float):
	if Input.is_action_just_pressed("pause"):
		pause() 


func _on_login_pressed() -> void:
	Global.restart_scene()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_replay_pressed() -> void:
	pause() 
	
	
func pause() -> void:
	get_tree().paused = not get_tree().paused
	$ColorRect.visible = not $ColorRect.visible
	$TextureRect.visible = not $TextureRect.visible


func _on_save_pressed() -> void:
	Global.save_game(Player.info)
