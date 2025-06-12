extends Control

# Esta função é chamada quando o botão "PlayButton" é pressionado
func _on_button_pressed():
	print("Botão Jogar pressionado! Iniciando o jogo...")
	
	# Troca para a cena principal do jogo.
	var error_code = get_tree().change_scene_to_file("res://Main.tscn") 
	
	# Verificação de erro (opcional, mas bom para depuração)
	if error_code != OK:
		print("Erro ao tentar carregar a cena do jogo: ", error_code)
