extends Node2D

var hud_scene = preload("res://HUD.tscn")
var hud

func _ready():
	hud = hud_scene.instantiate()
	add_child(hud)
	

# Quando o jogador cruza a linha de largada
func _on_start_area_body_entered(body):
	if body.name == "Player":
		$HUD.start_timer()

# Quando o jogador cruza a linha de chegada
func _on_finish_area_body_entered(body):
	if body.name == "Player":
		$HUD.stop_timer()
		# Aqui você pode adicionar lógica para finalizar a corrida
