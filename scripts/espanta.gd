extends Panel

@export var tower = preload("res://scenes/towers/espanta_pajaros.tscn") 
var currTile

func _on_gui_input(event: InputEvent) -> void:
	var tempTower = tower.instantiate()
	if event is InputEventMouseButton and event.button_mask == 1:
		add_child(tempTower)
		tempTower.process_mode = Node.PROCESS_MODE_DISABLED
		tempTower.get_node("Area").show()
		
		
	elif event is InputEventMouseMotion and event.button_mask == 1:
		if get_child_count() >= 1:
			get_child(1).global_position = event.global_position
	
	elif event is InputEventMouseButton and event.button_mask == 0:
		print("bye")
		tempTower.get_node("Area").hide()

		if event.global_position.x >= 1792:
			if get_child_count() >1:
				get_child(1).queue_free()
		else:
			var path = get_tree().get_root().get_node("Mapa/towers")
			path.add_child(tempTower)
			tempTower.global_position = event.global_position
			tempTower.get_node("Area").hide()
	else: 
		if get_child_count() > 1:
			get_child(1).queue_free()
