extends Node # Ou o tipo do seu nó gerenciador

# Referência à instância da DialogueBox na cena
# Use o caminho correto para a sua instância!
@onready var dialogue_box = $DialogueBox # Ou $Path/To/DialogueBox

# Variáveis para guardar dados do diálogo (exemplo)
var npc_portrait: Texture = preload("res://assets/Sprites/placeholderNpc.jpg") # Carregue a textura do retrato
var player_portrait: Texture = preload("res://assets/Sprites/Police.png")

func _ready():
	# Conecta o sinal de fim de diálogo a uma função local (opcional)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

# Exemplo de função para iniciar uma cutscene/diálogo
func start_tutorial_dialogue():
	# Pausa o jogo (se necessário)
	get_tree().paused = true 
	# Garante que a DialogueBox processe mesmo pausado
	dialogue_box.process_mode = Node.PROCESS_MODE_ALWAYS 

	# Define as linhas de diálogo
	var dialogue_sequence = [
		{"speaker": "Instrutor", "portrait": npc_portrait, "lines": [
			"Olá, novato! Bem-vindo ao Organ Rush.",
			"Sua missão é entregar órgãos vitais o mais rápido possível."
		]},
		{"speaker": "Jogador", "portrait": player_portrait, "lines": [
			"Entendido! Estou pronto para acelerar."
		]},
		{"speaker": "Instrutor", "portrait": npc_portrait, "lines": [
			"Ótimo! Lembre-se, o tempo é crucial. Boa sorte!"
		]}
	]
	
	# Inicia a primeira parte da sequência
	_play_dialogue_part(dialogue_sequence, 0)

# Função auxiliar para tocar partes sequenciais do diálogo
func _play_dialogue_part(sequence: Array, index: int):
	if index >= sequence.size():
		# Sequência terminou, pode chamar _on_dialogue_finished diretamente se quiser
		_on_dialogue_finished() 
		return

	var part = sequence[index]
	# Chama a função da caixa de diálogo, passando os dados
	dialogue_box.start_dialogue(part["lines"], part["portrait"], part["speaker"])
	# Guarda o índice da próxima parte para quando o diálogo atual terminar
	dialogue_box.set_meta("next_dialogue_index", index + 1)
	dialogue_box.set_meta("dialogue_sequence", sequence)

# Função chamada quando o sinal dialogue_finished é emitido pela DialogueBox
func _on_dialogue_finished():
	# Verifica se há uma próxima parte na sequência guardada nos metadados
	if dialogue_box.has_meta("next_dialogue_index"):
		var next_index = dialogue_box.get_meta("next_dialogue_index")
		var sequence = dialogue_box.get_meta("dialogue_sequence")
		# Limpa metadados para evitar chamadas repetidas
		dialogue_box.remove_meta("next_dialogue_index") 
		dialogue_box.remove_meta("dialogue_sequence")
		# Toca a próxima parte
		_play_dialogue_part(sequence, next_index)
	else:
		# O diálogo realmente acabou, despausa o jogo
		print("Sequência de diálogo completa. Retomando o jogo.")
		get_tree().paused = false
		# Reseta o process_mode da dialogue_box se necessário
		# dialogue_box.process_mode = Node.PROCESS_MODE_INHERIT 

# Exemplo de como chamar o início do diálogo (pode ser ao entrar numa área, etc.)
func _on_some_trigger_activated():
	start_tutorial_dialogue()


# Exemplo dentro do script onde você conectou o sinal

# Referência à instância da DialogueBox (precisa estar acessível)

# Função conectada ao body_entered do DialogueTriggerPoint
func _on_dialogue_trigger_point_body_entered(body):
	# Verifica se quem entrou foi realmente o jogador
	if body.is_in_group("player"): # Usar grupos é uma boa prática!
		print("Jogador entrou na área de diálogo!")
		
		# Chama a função que inicia a sequência de diálogo
		# (Usando o exemplo da mensagem anterior)
		start_tutorial_dialogue() 
		
		# Opcional: Desativar o trigger para não disparar de novo
		# $DialogueTriggerPoint/CollisionShape2D.disabled = true 
		# Ou desativar a monitoração da Area2D
		# $DialogueTriggerPoint.monitoring = false
		# Ou remover o trigger da cena
		# $DialogueTriggerPoint.queue_free()

# ... (resto do script, incluindo a função start_tutorial_dialogue)
