extends CanvasLayer

# Sinal emitido quando a caixa de diálogo termina
signal dialogue_finished

# Referências aos nós da interface (ajuste os caminhos se necessário)
@onready var dialogue_panel = $DialoguePanel
@onready var portrait_rect = $DialoguePanel/TextureRect
@onready var text_label = $DialoguePanel/Label
@onready var name_label = $DialoguePanel/NameLabel # Descomente se você adicionou

# Variáveis de controle
var dialogue_lines: Array = [] # Fila de linhas de diálogo a exibir
var current_line_index: int = 0
var current_text: String = ""
var display_text: String = ""
var typing_speed: float = 0.05 # Segundos por caractere (ajuste a gosto)
var is_typing: bool = false
var can_advance: bool = false

@onready var typing_timer = Timer.new()

func _ready():
	# Esconde a caixa ao iniciar
	hide()
	# Configura o timer para o efeito de digitação
	typing_timer.wait_time = typing_speed
	typing_timer.one_shot = true
	typing_timer.connect("timeout", Callable(self, "_on_typing_timer_timeout"))
	add_child(typing_timer)
	# Esconde o indicador inicialmente (se existir)
	# if indicator: indicator.hide()

# Função principal para iniciar o diálogo
func start_dialogue(lines: Array, portrait: Texture = null, speaker_name: String = ""):
	if lines.is_empty():
		print("Erro: Nenhuma linha de diálogo fornecida.")
		return
		
	dialogue_lines = lines
	current_line_index = 0
	is_typing = false
	can_advance = false
	
	# Configura retrato e nome (se houver)
	if portrait_rect:
		portrait_rect.texture = portrait
		portrait_rect.visible = (portrait != null)
	# if name_label:
	#     name_label.text = speaker_name
	#     name_label.visible = (speaker_name != "")
		
	# Mostra a caixa e começa a primeira linha
	show()
	_load_next_line()

# Carrega a próxima linha de diálogo
func _load_next_line():
	if current_line_index >= dialogue_lines.size():
		_finish_dialogue()
		return

	current_text = dialogue_lines[current_line_index]
	display_text = ""
	text_label.text = ""
	is_typing = true
	can_advance = false
	# if indicator: indicator.hide() # Esconde indicador enquanto digita
	
	# Inicia o timer para o primeiro caractere
	typing_timer.start()

# Chamado quando o timer de digitação termina (para adicionar um caractere)
func _on_typing_timer_timeout():
	if display_text.length() < current_text.length():
		display_text += current_text[display_text.length()]
		text_label.text = display_text
		# Reinicia o timer para o próximo caractere
		typing_timer.start()
	else:
		# Terminou de digitar a linha atual
		is_typing = false
		can_advance = true
		# if indicator: indicator.show() # Mostra indicador
		# Aqui você pode adicionar uma animação simples ao indicador (piscar, etc.)

# Processa input do jogador
func _input(event):
	# Verifica se a caixa está visível e se há uma ação de "confirmar" pressionada
	if visible and event.is_action_pressed("ui_accept"): # "ui_accept" é geralmente Enter ou Espaço
		if is_typing:
			# Se está digitando, pula a animação e mostra o texto completo
			typing_timer.stop()
			display_text = current_text
			text_label.text = display_text
			is_typing = false
			can_advance = true
			# if indicator: indicator.show()
			# Aceita o evento para não processar mais nada
			get_viewport().set_input_as_handled()
		elif can_advance:
			# Se não está digitando e pode avançar, carrega a próxima linha
			current_line_index += 1
			_load_next_line()
			# Aceita o evento
			get_viewport().set_input_as_handled()

# Chamado quando todas as linhas foram exibidas
func _finish_dialogue():
	print("Diálogo finalizado.")
	hide()
	dialogue_lines.clear()
	current_line_index = 0
	emit_signal("dialogue_finished")
