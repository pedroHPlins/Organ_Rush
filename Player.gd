extends CharacterBody2D
# Iniciar a HUD
@onready var hud = get_tree().get_nodes_in_group("hud")[0]
@onready var engine_sound = $EngineSound

# Configurações de movimento
@export var max_speed = 540
@export var acceleration = 85
@export var steering = 2.0
@export var friction = 0.99
@export var drift_factor = 0.95

# Configurações de dano
@export var collision_damage = 10
@export var min_collision_speed = 30  # Velocidade mínima para causar dano
@export var damage_cooldown = 1.0     # Tempo entre danos consecutivos

var last_damage_time = 0.0
var can_take_damage = true

var speed = 0
var drift = false
var engine_playing = false


func _physics_process(delta):
	# Capturar entrada do jogador
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	input.y = Input.get_action_strength("accelerate") - Input.get_action_strength("brake")
	
	# Controle de derrapagem
	drift = Input.is_action_pressed("drift")
	
	# Aplicar movimento
	apply_movement(input, delta)
	apply_steering(input.x, delta)
	
	# Movimentar o corpo
	set_velocity(velocity)
	move_and_slide()
	velocity = velocity
	
	# Controlar som do motor baseado no movimento
	control_engine_sound()
	
	# Atualiza Velocimetro HUD
	if hud:
		var speed = velocity.length()
		var speed_kmh = speed / 3.6  # Converte para km/h
		hud.update_speed(speed_kmh)
	else:
		print("HUD não encontrado!")
		
	handle_collision_damage(delta)
	
	# Efeito de derrapagem
	if drift and abs(input.x) > 0.1 and speed > 100:
		emit_drift_particles()

func control_engine_sound():
	# Toca o som do motor quando o carro está se movendo
	var current_speed = abs(speed)
	
	if current_speed > 50 and not engine_playing:
		# Inicia o som do motor
		if engine_sound:
			engine_sound.play()
			engine_playing = true
			print("Motor ligado!")
	elif current_speed <= 50 and engine_playing:
		# Para o som do motor
		if engine_sound:
			engine_sound.stop()
			engine_playing = false
			print("Motor desligado!")
	
	# Ajusta o volume baseado na velocidade (opcional)
	if engine_playing and engine_sound:
		var volume_factor = clamp(current_speed / max_speed, 0.3, 1.0)
		engine_sound.volume_db = -20.0 + (volume_factor * 15.0)  # Volume entre -20db e -5db
		
func handle_collision_damage(delta):
		# Atualiza temporizador de cooldown
		if !can_take_damage:
			last_damage_time += delta
			if last_damage_time >= damage_cooldown:
				can_take_damage = true
				last_damage_time = 0.0
	# Verifica colisões apenas se pode tomar dano
		if can_take_damage && get_slide_collision_count() > 0:
			var current_speed = speed		
		# Só causa dano se a velocidade for significativa
			if current_speed > min_collision_speed:
			# Calcula dano proporcional à velocidade
				var damage = collision_damage * (current_speed / max_speed)
				hud.damage_organ(ceil(damage))
			
				# Reduz velocidade no impacto (efeito de batida)
				speed = speed * 0.7
			
				# Ativa cooldown
				can_take_damage = false
				last_damage_time = 0.0
				
				print("Colisão detectada")

func apply_movement(input, delta):
	# Aceleração e freio
	if input.y != 0:
		speed += input.y * acceleration * delta
	else:
		speed *= friction
	
	speed = clamp(speed, -max_speed/3, max_speed)  # Ré mais lenta
	
	# Converter velocidade para vetor
	var forward_vector = Vector2(cos(rotation), sin(rotation))
	velocity = forward_vector * speed
	
	# Reduzir velocidade lateral ao derrapar
	if drift:
		var side_velocity = velocity.dot(Vector2(-forward_vector.y, forward_vector.x))
		velocity -= Vector2(-forward_vector.y, forward_vector.x) * side_velocity * (1 - drift_factor)

func apply_steering(steer_input, delta):
	# Só vira se estiver se movendo
	if abs(speed) > 50:
		# Vira mais devagar quando está derrapando
		var steering_factor = steering * (drift_factor if drift else 1.0)
		rotation += steer_input * steering_factor * delta * (1.0 if speed > 0 else -1.0)

func emit_drift_particles():
	# Implementar partículas de derrapagem aqui
	pass
