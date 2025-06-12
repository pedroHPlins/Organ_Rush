extends CanvasLayer

# Referências aos nós do HUD
@onready var speed_label = $SpeedLabel
@onready var timer_label = $TimerLabel
@onready var organ_integrity = $OrganIntegrity
@onready var alarm_sound = $AlarmSound

# Variáveis de controle
var elapsed_time = 0.0
var is_timer_active = false
var alarm_threshold = 30.0  # Alarme toca quando restam 30 segundos
var delivery_time_limit = 120.0  # Limite de tempo para entrega (2 minutos)
var alarm_playing = false

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
		
		# Verifica se deve tocar o alarme
		var remaining_time = delivery_time_limit - elapsed_time
		if remaining_time <= alarm_threshold and remaining_time > 0 and not alarm_playing:
			play_alarm()
		elif remaining_time <= 0:
			stop_alarm()
			# Aqui você pode adicionar lógica para quando o tempo acabar

# Atualiza o velocímetro
func update_speed(speed):
	speed_label.text = "Velocidade: %.1f km/h" % speed


# Atualiza o timer
func update_timer(time):
	var remaining_time = delivery_time_limit - time
	if remaining_time < 0:
		remaining_time = 0
	
	var minutes = int(remaining_time / 60)
	var seconds = int(remaining_time) % 60
	timer_label.text = "Tempo: %02d:%02d" % [minutes, seconds]

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
	stop_alarm()

# Toca o som de alarme
func play_alarm():
	if alarm_sound and not alarm_playing:
		alarm_sound.play()
		alarm_playing = true
		print("Alarme ativado! Tempo restante crítico!")

# Para o som de alarme
func stop_alarm():
	if alarm_sound and alarm_playing:
		alarm_sound.stop()
		alarm_playing = false

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
