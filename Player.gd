extends CharacterBody2D

# Configurações de movimento
@export var max_speed = 250
@export var acceleration = 80
@export var steering = 2.5
@export var friction = 0.97
@export var drift_factor = 0.95

var speed = 0
var drift = false

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
	
	# Efeito de derrapagem
	if drift and abs(input.x) > 0.1 and speed > 100:
		emit_drift_particles()

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
