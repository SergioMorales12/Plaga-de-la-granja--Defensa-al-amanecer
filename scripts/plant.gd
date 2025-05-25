extends Node2D

@export var attack_interval := 10.0
@export var price: float = 1000
@export var escala: float = 1
@export var hp: float = 5
@export var gold: float = 200

var can_attack = true

func _ready():
	$attack_timer.wait_time = attack_interval
	$attack_timer.start()

	$AnimatedSprite2D.play("idle")


func _on_attack_timer_timeout():
	if can_attack:
		var action = randi() % 2
		match action:
			0:
				heal()
			1:
				generate_money()


func heal():
	$AnimatedSprite2D.play("hp")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("idle")
	Player.player_life += hp
	Player.update_ui()


func generate_money():
	$AnimatedSprite2D.play("money")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("idle")
	Player.player_gold += gold
	Player.update_ui()
