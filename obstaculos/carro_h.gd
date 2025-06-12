extends CharacterBody2D

@export var velocidade_max = 50
@export var aceleracao = 20
@export var baixo = true

@onready var raycast_2d: RayCast2D = $"RayCast2D"
@onready var sprite_2d: Sprite2D = $"Sprite2D"

var direcao = 1
var speed = 0

func _ready():
	if baixo:
		raycast_2d.position.y = 25
		raycast_2d.rotation = 0
		direcao = 1
		sprite_2d.flip_v = false
	else:
		raycast_2d.position.y = -25
		raycast_2d.rotation = 3.14
		direcao = -1
		sprite_2d.flip_v = true

func _physics_process(delta):
	if raycast_2d.is_colliding():
		_desacelarCarro(delta)
	else:
		if speed < velocidade_max:
			speed += aceleracao * delta 
			velocity.y = speed * direcao
		else:
			velocity.y = velocidade_max * direcao
	velocity.x = 0
	move_and_slide()
	velocity = velocity



func _desacelarCarro(delta):
	
	if speed > 10 :
		print("paroparo")
		speed -= aceleracao * 5 * delta 
	else:
		speed = 0
