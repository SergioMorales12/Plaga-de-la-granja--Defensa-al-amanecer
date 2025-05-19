extends Control

@export var textDialogo = "Me gustan las milffffsssss"
var delayTalking = true

func _ready() -> void:
	dialogo()
	

func dialogo():
	var texto= ""
	var count = 26
	var jumps = 3
	if delayTalking:
		for i in textDialogo:
			
			print(texto)
			$Control/Label.text = texto
			if count < 1:
				jumps -= 1
				texto += "/n"
				count = 26
			texto += i
			count -=1
	


func _on_timer_timeout() -> void:
	delayTalking != delayTalking
