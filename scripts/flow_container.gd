extends FlowContainer

@export var towers_to_add: Dictionary = {    
	"espantapajaros": preload("res://scenes/towers/espanta_pajaros.tscn"),
	"molino": preload("res://scenes/towers/molino.tscn"),
	"barril": preload("res://scenes/towers/barril.tscn"),
	"microwave": preload("res://scenes/towers/microwave.tscn"),
	"plant": preload("res://scenes/towers/plant.tscn")
}

@export var initially_unlocked: Array[String] = ["espantapajaros", "molino"]

var panel_scene = preload("res://scenes/panel.tscn")
var tower_panels: Dictionary = {}  

func _ready() -> void:
	Dialogic.connect("signal_event", Callable(self, "_on_dialogic_signal"))
	Player.unlocked_towers = initially_unlocked
	create_initial_panels()

func create_initial_panels():
	# Crear solo las torres inicialmente desbloqueadas
	for tower_name in initially_unlocked:
		if towers_to_add.has(tower_name):
			create_tower_panel(tower_name, towers_to_add[tower_name])

func create_tower_panel(tower_name: String, tower_scene: PackedScene):
	var new_panel = panel_scene.instantiate()
	new_panel.tower = tower_scene
	
	# Guardar referencia al panel
	tower_panels[tower_name] = new_panel
	
	# Configuración adicional del panel
	new_panel.name = tower_name + "_panel"
	new_panel.visible = true
	
	add_child(new_panel)

func unlock_tower(tower_name: String):
	Player.unlocked_towers.append(tower_name)
	if towers_to_add.has(tower_name) and not tower_panels.has(tower_name):
		create_tower_panel(tower_name, towers_to_add[tower_name])
		
		if tower_panels[tower_name].has_method("play_unlock_effect"):
			tower_panels[tower_name].play_unlock_effect()

func _on_dialogic_signal(argument: String):
	match argument:
		"unlock_barril":
			unlock_tower("barril")
		"unlock_microwave":
			unlock_tower("microwave")
		"unlock_plant":
			unlock_tower("plant")
		_:
			print("Señal desconocida recibida: ", argument)

func _on_settings_pressed() -> void:
	Input.action_press("pause")
	Input.action_release("pause")



func _on_x_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Engine.time_scale = 2.0
	else:
		Engine.time_scale = 1.0
