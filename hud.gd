extends CanvasLayer

# Referências aos nós do HUD
@onready var speed_label = $SpeedLabel
@onready var timer_label = $TimerLabel
@onready var organ_integrity = $OrganIntegrity

# Variáveis de controle
var elapsed_time = 0.0
var is_timer_active = false

func _ready():
	# Inicializa o HUD
	update_timer(0)
	update_organ_integrity(100)
	start_timer()
	
		# Configurações essenciais
	organ_integrity.min_value = 0
	organ_integrity.max_value = 100
	organ_integrity.value = 100  # Valor inicial
	organ_integrity.show_percentage = true  # Mostra porcentagem
	
	add_to_group("hud")

func _process(delta):
	# Atualiza o timer se estiver ativo
	if is_timer_active:
		elapsed_time += delta
		update_timer(elapsed_time)

# Atualiza o velocímetro
func update_speed(speed):
	speed_label.text = "Velocidade: %.1f km/h" % speed


# Atualiza o timer
func update_timer(time):
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

# Atualiza a integridade do órgão
func update_organ_integrity(value):
	organ_integrity.value = value
	print("Integridade atualizada!")

# Inicia o timer
func start_timer():
	elapsed_time = 0.0
	is_timer_active = true

# Para o timer
func stop_timer():
	is_timer_active = false

# Reduz a integridade do órgão (chamado quando houver colisão)
func damage_organ(amount):
	var new_integrity = organ_integrity.value - amount
	update_organ_integrity(new_integrity)
	print("Dano registrado:", new_integrity)
	
	# Força a atualização visual
	organ_integrity.queue_redraw()
	
	if new_integrity < 0:
		new_integrity = 0
		# Aqui você pode adicionar lógica para quando o órgão estiver completamente danificado
