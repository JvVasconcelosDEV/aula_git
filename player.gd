extends CharacterBody2D  # O personagem herda de CharacterBody2D

var input  # Variável para armazenar o input do jogador
@export var speed = 100.0  # Velocidade do personagem
@export var gravity = 8  # Força da gravidade aplicada ao personagem
signal _changed(player_hearts)
# Variáveis para controlar o pulo
var jump_count = 0  # Contador de pulos
@export var max_jump = 2  # Número máximo de pulos permitidos
@export var jump_force = 275  # Força aplicada ao pular
@export var dash_force = 3000
var onladder = false  # Indica se o personagem está em uma escada
var max_hearts: int = 2
var hearts: float = max_hearts
# Variáveis relacionadas à State Machine
var current_state = player_states.MOVE  # Estado atual do personagem
enum player_states {MOVE, SWORD, DASH}  # Definição dos estados possíveis

func _ready():
	# Desabilita o colisor da espada ao iniciar
	$sword/SwordCollider.disabled = true


func _physics_process(delta):
	if onladder:
		# Se o personagem está em uma escada, a gravidade é zerada
		gravity = 0
		if Input.is_action_pressed("ui_up"):  # Move para cima na escada
			velocity.y = -speed
		elif Input.is_action_pressed("ui_down"):  # Move para baixo na escada
			velocity.y = speed
		else:
			velocity.y = 0  # Se nenhuma tecla é pressionada, o personagem não se move verticalmente
	else:
		# Se o personagem não está na escada, a gravidade é restaurada
		gravity = 8
		gravity_force()  # Aplica a gravidade ao personagem
		
	# Verifica o estado atual do personagem
	match current_state:
		player_states.MOVE:
			movement(delta)  # Chama a função de movimento
		player_states.SWORD:
			sword(delta)  # Chama a função de ataque com espada
		player_states.DASH:
				dashing()

	
func movement(delta):
	# Calcula a direção do movimento com base no input do jogador
	input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	# Se há input de movimento, o personagem se move
	if input != 0:
		if input > 0:  # Movimentação para a direita
			velocity.x += speed * delta
			velocity.x = clamp(speed, 100, speed)  # Limita a velocidade a 100
			$Sprite2D.scale.x = 1  # Define a direção do sprite para a direita
			$sword.position.x = 19  # Ajusta a posição da espada
			$anim.play("Walk")  # Toca a animação de andar
		if input < 0:  # Movimentação para a esquerda
			velocity.x -= speed * delta
			velocity.x = clamp(-speed, 100, -speed)  # Limita a velocidade a -100
			$Sprite2D.scale.x = -1  # Define a direção do sprite para a esquerda
			$sword.position.x = -19  # Ajusta a posição da espada
			$anim.play("Walk")  # Toca a animação de andar

	
	# Se não houver input de movimento, o personagem fica parado
	if input == 0:
		velocity.x = 0
		$anim.play("Idle")  # Toca a animação de idle (parado)
	
	# Lógica para pular
	if is_on_floor():  # Reseta o contador de pulo quando está no chão
		jump_count = 0
	
	# Define as animações de pulo e queda
	if !is_on_floor():
		if velocity.y < 0:
			$anim.play("Jump")  # Animação de pulo
		if velocity.y > 0:
			$anim.play("Fall")  # Animação de queda
	
	# Verifica se o jogador pressionou a tecla de pulo e está no chão
	if Input.is_action_pressed("Jump") and is_on_floor() and jump_count < max_jump:
		jump_count += 1  # Incrementa o contador de pulo
		velocity.y = -jump_force  # Aplica a força do pulo
	
	# Permite um segundo pulo enquanto o personagem está no ar
	if !is_on_floor() and Input.is_action_just_pressed("Jump") and jump_count < max_jump:
		jump_count += 1
		velocity.y = -jump_force  # Aplica a força do segundo pulo
	
	# Se o jogador soltar o botão de pulo, aplica uma gravidade maior
	if !is_on_floor() and Input.is_action_just_released("Jump") and jump_count < max_jump:
		velocity.y = gravity * 1.5
		velocity.x -= input  # Reduz a velocidade no ar
	else:
		gravity_force()  # Aplica a gravidade normalmente
	
	# Move o personagem e resolve colisões
	move_and_slide()
	
	# Verifica se o jogador pressionou a tecla de ataque
	if Input.is_action_just_pressed("ui_attack"):
		current_state = player_states.SWORD  # Muda o estado para o de ataque
		
	if Input.is_action_just_pressed("ui_dash"):
		current_state = player_states.DASH



func gravity_force():
	# Função que aplica a força da gravidade no personagem
	velocity.y += gravity

func sword(delta):
	# Executa a animação de ataque
	$anim.play("Sword")
	attacknmove(delta)  # Continua o movimento durante o ataque
	
	
func dashing():
	if velocity.x > 0:
		velocity.x += dash_force
		await get_tree().create_timer(0.1).timeout
		current_state = player_states.MOVE
	elif velocity.x < 0:
		velocity.x -= dash_force
		await get_tree().create_timer(0.1).timeout
		current_state = player_states.MOVE
	else:
		if $Sprite2D.scale.x == 1:
			velocity.x += dash_force
		await get_tree().create_timer(0.1).timeout
		current_state = player_states.MOVE
		if $Sprite2D.scale.x == -1:
			velocity.x -= dash_force
		await get_tree().create_timer(0.1).timeout
		current_state = player_states.MOVE
		
	move_and_slide()
	
func attacknmove(delta):
	# Lógica de movimentação durante o ataque
	if input != 0:
		if input > 0:  # Movimentação para a direita
			velocity.x += speed * delta
			velocity.x = clamp(speed, 100, speed)  # Limita a velocidade
		if input < 0:  # Movimentação para a esquerda
			velocity.x -= speed * delta
			velocity.x = clamp(-speed, 100, -speed)
	if input == 0:
		velocity.x = 0  # Personagem para se não houver input
	
	# Move o personagem e resolve colisões
	move_and_slide()

func reset_states():
	# Função para resetar o estado do personagem para o de movimento
	current_state = player_states.MOVE
