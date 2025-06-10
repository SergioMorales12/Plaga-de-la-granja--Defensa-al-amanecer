extends Node

# Diálogos especiales por oleada exacta
var special_wave_dialogs := {
	1: "intro_tutorial",
	5: "primer_enjambre",
	10: "primer_boss",
	33:"como_33",
	40:"lore_planta"
}
func _ready():
	await Player.update_data()



func play_wave_dialog(current_wave: int) -> void:
	if special_wave_dialogs.has(current_wave):
		# Mostrar diálogo especial
		Dialogic.start(special_wave_dialogs[current_wave])
		
	else:
		# Mostrar diálogo aleatorio (30% de probabilidad)
		if randi_range(0, 100) < 0:
			Dialogic.start("random_wave_%d" % randi_range(1, 19)) 
