extends CanvasLayer

func _physics_process(delta: float):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
		$ColorRect.visible = not $ColorRect.visible
		$Label.visible = not $Label.visible
		$buttons.visible = not $buttons.visible


func _on_login_pressed() -> void:
	Global.restart_scene()
