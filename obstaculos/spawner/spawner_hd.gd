extends Node2D


@onready var carro = preload("res://obstaculos/carroH.tscn")

@export var baixo = true


func _on_timer_timeout():
	var car = carro.instantiate() 
	car.baixo = baixo
	car.position = position
	get_parent().add_child(car)
