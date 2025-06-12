extends Node2D


@onready var carro = preload("res://obstaculos/carroV.tscn")

@export var direita = true


func _on_timer_timeout():
	var car = carro.instantiate() 
	car.direita = direita
	car.position = position
	get_parent().add_child(car)
