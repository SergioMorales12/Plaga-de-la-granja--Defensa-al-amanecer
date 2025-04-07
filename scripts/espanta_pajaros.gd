extends Node2D

@export var original_sprite: Texture
@export var alternate_sprite: Texture

func _ready():
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
	$Area2D.connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.is_in_group("enemi"):
		$Sprite.texture = alternate_sprite

func _on_body_exited(body):
	if body.is_in_group("enemigo"):
		var overlapping_bodies = $Area2D.get_overlapping_bodies()
		var enemy_present = false
		for b in overlapping_bodies:
			if b.is_in_group("enemigo"):
				enemy_present = true
				break
		if not enemy_present:
			$Sprite.texture = original_sprite
